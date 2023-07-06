terraform {
  backend "s3" {
    bucket = "tf-cr-state-sb77777"
    key    = "infra/aws_infra"
    region = "us-west-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "tf-cr-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}