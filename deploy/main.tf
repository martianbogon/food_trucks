provider "aws" {
  region = "us-east-2"
}

data "aws_caller_identity" "current" {}

module "s3" {
  source = "./modules/s3"
}

module "lambda" {
  source = "./modules/lambda"

  bucket = module.s3.bucket
  key    = "foodtrucks.csv"
}

module "api_gateway" {
  source = "./modules/api_gateway"

  myregion             = "us-east-2"
  accountId            = data.aws_caller_identity.current.account_id
  lambda_function_name = module.lambda.lambda_function_name
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn
}
