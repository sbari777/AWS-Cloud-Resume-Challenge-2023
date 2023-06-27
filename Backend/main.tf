provider "aws" {
  region = "us-west-2"
}

############IAM & CLOUDWATCH START#####################
#Cloudwatch Log group for Update Visitor Counter Lambda 
resource "aws_cloudwatch_log_group" "updateVisitorCount-lambda-log-group" {
  name              = "/aws/lambda/updateVisitorCount"
  retention_in_days = 30
}

#DynamoDB Read & Write IAM policy for Lambda Function to retrieve and update items from DynamoDB table
module "Lambda-DynamoDB-RW-iam-policy" {
  depends_on    = [aws_dynamodb_table.visitorcount-table]
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version       = "5.20.0"
  create_policy = true
  description   = "Read and Write Access for Lambda function to Visitor Count DynamoDB Table"
  path          = "/"
  name          = "Lambda-DynamoDB-RW"
  policy        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            "Effect": "Allow",
            "Resource": "${aws_dynamodb_table.visitorcount-table.arn}"
        }
    ]
}
EOF
}

#IAM policy that enables Lambda to write execution results to Cloudwatch Logs
module "Lambda-Cloudwatch-W-iam-policy" {
  depends_on    = [aws_cloudwatch_log_group.updateVisitorCount-lambda-log-group]
  source        = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version       = "5.20.0"
  create_policy = true
  description   = "Lambda Function limited write access to cloudwatch logs"
  path          = "/"
  name          = "AWS-Lambda-Basic-Execution-Role-CW"
  policy        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.updateVisitorCount-lambda-log-group.arn}:*"
            ]
        }
    ]
}
EOF
}

#Lambda execution role that has Lambda Cloudwatch policy and Lambda DynamoDB policy attached to it
module "Lambda-Function-Role" {
  source            = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  create_role       = true
  role_name         = "Visitor-Counter-Lambda-Function-Role"
  role_requires_mfa = false

  trusted_role_services = [
    "lambda.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.Lambda-Cloudwatch-W-iam-policy.arn,
    module.Lambda-DynamoDB-RW-iam-policy.arn
  ]
  number_of_custom_role_policy_arns = 2
}
############IAM & CLOUDWATCH END#######################

############DYNAMO DB START############################
#Creates dynamoDB table for storing visitor count
resource "aws_dynamodb_table" "visitorcount-table" {
  billing_mode   = var.dynamodb_billing_mode
  hash_key       = var.dynamodb_partition_key
  name           = var.dynamodb_table_name
  stream_enabled = false
  table_class    = var.dynamodb_table_storage_class

  attribute {
    name = "visitorCount"
    type = "S"
  }

  point_in_time_recovery {
    enabled = false
  }

  timeouts {}

  tags = {
    Name        = "VisitorCount-DynamoDBTable"
    Environment = "production"
  }

  ttl {
    attribute_name = ""
    enabled        = false
  }
}

#Enter existing visitor count number as input variable before Terraform apply. Ensures continuity of visitor count when infra re-built. 
#Adds the number item to "count" into table Visitor Count
resource "aws_dynamodb_table_item" "replace-count-value" {
  depends_on = [aws_dynamodb_table.visitorcount-table]
  table_name = aws_dynamodb_table.visitorcount-table.name
  hash_key   = aws_dynamodb_table.visitorcount-table.hash_key

  item = <<ITEM
{
  "visitorCount": {"S": "visitorCount"},
  "count": {"N": "${var.current_count_number}"}
}
ITEM
}

############DYNAMO DB END##############################


############LAMBDA FUNCTION START######################
#creates the lambda function that retrieves from or updates the dynamodb visitorcount table
#code is hosted in s3 bucket
resource "aws_lambda_function" "UPDATE-VISITOR-COUNTER-FUNCTION" {
  depends_on = [module.Lambda-Function-Role]
  architectures = [
    "x86_64",
  ]
  function_name = "updateVisitorCount"
  role          = module.Lambda-Function-Role.iam_role_arn
  runtime       = "python3.10"
  handler       = "lambda_function.lambda_handler"
  s3_bucket     = var.s3_lambda_function_bucket
  s3_key        = var.s3_key_lambda_function_file
  skip_destroy  = false

  ephemeral_storage {
    size = 512
  }

  tracing_config {
    mode = "PassThrough"
  }
}

#Permission policy that allows lambda to be invoked via API Gateway trigger.
resource "aws_lambda_permission" "VC-APIGW-ALLOW-INVOKE-FUNCTION" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.UPDATE-VISITOR-COUNTER-FUNCTION.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.VisitorCounter-API.execution_arn}/*/${aws_api_gateway_method.VC-API-GET.http_method}${aws_api_gateway_resource.VC-API-METHODS.path}"
}
############LAMBDA FUNCTION END#########################


############API GATEWAY START###########################
#Creates the API Gateway infrastructure by following its workflow:
#1. Create REST API
#2. Create resource within API
#3. Create resource method i.e get, post
#4. Create method integration
#5. Create method response
#6. Create integration response

#1. Create REST API
resource "aws_api_gateway_rest_api" "VisitorCounter-API" {
  name              = "VisitorCounter"
  put_rest_api_mode = "overwrite"
  api_key_source    = "HEADER"
  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }

  tags = {
    Name        = "VisitorCount-API"
    Environment = "Production"
  }
}

#2. Create resource within API
resource "aws_api_gateway_resource" "VC-API-METHODS" {
  path_part   = "VC-API-METHODS"
  parent_id   = aws_api_gateway_rest_api.VisitorCounter-API.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.VisitorCounter-API.id
}

#3. Create resource method - GET
resource "aws_api_gateway_method" "VC-API-GET" {
  rest_api_id      = aws_api_gateway_rest_api.VisitorCounter-API.id
  resource_id      = aws_api_gateway_resource.VC-API-METHODS.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
}

#4. Create method integration with lambda function invoke arn
resource "aws_api_gateway_integration" "VC-GET-LAMBDA-POST" {
  depends_on              = [aws_lambda_function.UPDATE-VISITOR-COUNTER-FUNCTION]
  rest_api_id             = aws_api_gateway_rest_api.VisitorCounter-API.id
  resource_id             = aws_api_gateway_resource.VC-API-METHODS.id
  http_method             = aws_api_gateway_method.VC-API-GET.http_method
  timeout_milliseconds    = 29000
  passthrough_behavior    = "WHEN_NO_MATCH"
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.UPDATE-VISITOR-COUNTER-FUNCTION.invoke_arn

}

#5. Create the succesful GET method response of status code 200
resource "aws_api_gateway_method_response" "VC-API-GET-RESPONSE-200" {
  rest_api_id = aws_api_gateway_rest_api.VisitorCounter-API.id
  resource_id = aws_api_gateway_resource.VC-API-METHODS.id
  http_method = aws_api_gateway_method.VC-API-GET.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
  }
}

#6. Create the GET integration response 
resource "aws_api_gateway_integration_response" "VC-API-GET-INTEGRATION-RESPONSE" {
  depends_on  = [aws_api_gateway_integration.VC-GET-LAMBDA-POST]
  rest_api_id = aws_api_gateway_rest_api.VisitorCounter-API.id
  resource_id = aws_api_gateway_resource.VC-API-METHODS.id
  http_method = aws_api_gateway_method.VC-API-GET.http_method
  status_code = aws_api_gateway_method_response.VC-API-GET-RESPONSE-200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.domain_name}'",
  }
}

#Creation of OPTIONS method to enable CORS. 
resource "aws_api_gateway_method" "VC-API-OPTIONS" {
  rest_api_id      = aws_api_gateway_rest_api.VisitorCounter-API.id
  resource_id      = aws_api_gateway_resource.VC-API-METHODS.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

#Create MOCK integration for OPTIONS method. Requests return a predefined response if there is no existing matching backend.
resource "aws_api_gateway_integration" "VC-API-OPTIONS-MOCK-INTEGRATION" {
  rest_api_id = aws_api_gateway_rest_api.VisitorCounter-API.id
  resource_id = aws_api_gateway_resource.VC-API-METHODS.id
  http_method = aws_api_gateway_method.VC-API-OPTIONS.http_method

  type                 = "MOCK"
  timeout_milliseconds = 29000
  passthrough_behavior = "WHEN_NO_MATCH"
  connection_type      = "INTERNET"

  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

#200 status code for successful OPTIONS method responses, and enables CORS by specifying response parameters
resource "aws_api_gateway_method_response" "VC-API-OPTIONS-RESPONSE-200" {
  rest_api_id = aws_api_gateway_rest_api.VisitorCounter-API.id
  resource_id = aws_api_gateway_resource.VC-API-METHODS.id
  http_method = aws_api_gateway_method.VC-API-OPTIONS.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true,
  }
}


#MOCK integration reponse. Allows specific headers and methods, and traffic from a specific domain.
resource "aws_api_gateway_integration_response" "VC-API-OPTIONS-MOCK-INTEGRATION-RESPONSE" {
  rest_api_id = aws_api_gateway_rest_api.VisitorCounter-API.id
  resource_id = aws_api_gateway_resource.VC-API-METHODS.id
  http_method = aws_api_gateway_method.VC-API-OPTIONS.http_method
  status_code = aws_api_gateway_method_response.VC-API-OPTIONS-RESPONSE-200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.domain_name}'",
  }
}

#Deploys the defined API Gateway configuration to production. Specifies explicit dependenices that need to be created prior to its creations
resource "aws_api_gateway_deployment" "VC-API-DEPLOY" {
  depends_on = [
    aws_api_gateway_method.VC-API-GET,
    aws_api_gateway_method.VC-API-OPTIONS,
    aws_api_gateway_integration.VC-API-OPTIONS-MOCK-INTEGRATION,
    aws_api_gateway_integration.VC-GET-LAMBDA-POST
  ]

  rest_api_id = aws_api_gateway_rest_api.VisitorCounter-API.id


  lifecycle {
    create_before_destroy = true
  }
}

#Creates a "Production" stage for the deployed API.
resource "aws_api_gateway_stage" "VC-API-PRODUCTION-STAGE" {
  deployment_id         = aws_api_gateway_deployment.VC-API-DEPLOY.id
  rest_api_id           = aws_api_gateway_rest_api.VisitorCounter-API.id
  stage_name            = "Production"
  cache_cluster_enabled = false
}

