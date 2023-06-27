#DynamoDB Parameters
variable "dynamodb_table_name" {
  type    = string
}

variable "dynamodb_billing_mode" {
  type    = string
  default = "PAY_PER_REQUEST"
}

variable "dynamodb_partition_key" {
  type    = string
  default = "hash_key"
}

variable "dynamodb_table_storage_class" {
  type    = string
  default = "STANDARD"
}


variable "current_count_number" {
  type = number
}

#S3 Parameters for Lambda Function Source Code
variable "s3_lambda_function_bucket" {
  type = string
}

variable "s3_key_lambda_function_file" {
  type = string
}

#For CORS - specify Domain name to send requests to API 
variable "domain_name" {
  type = string
}