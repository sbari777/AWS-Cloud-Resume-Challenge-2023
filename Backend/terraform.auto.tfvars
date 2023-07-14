# update current visitor count number before re-deploying to retain current count, otherwise count resets to 0. 
dynamodb_table_name         = "VisitorCount"
dynamodb_partition_key      = "visitorCount"
current_count_number        = 821
s3_lambda_function_bucket   = "visitor-counter-lambda-function-0239458"
s3_key_lambda_function_file = "updateVisitorCount.zip"
domain_name                 = "https://saifbari.com"