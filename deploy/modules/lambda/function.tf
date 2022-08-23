resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "foodtrucks_lambda" {
  filename      = "../dist/food_trucks_lambda.zip"
  function_name = "foodtrucks_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../dist/food_trucks_lambda.zip")

  runtime = "python3.9"

  environment {
    variables = {
      BUCKET = var.bucket
      KEY    = var.key
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_funcs
  ]
}

resource "aws_cloudwatch_log_group" "lambda_funcs" {
  name              = "/aws/lambda/foodtrucks_lambda"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "lambda_access" {
  name        = "foodtruck_s3_access_policy"
  description = "Policy to give the lambda access to foodtruck data file"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
    "Effect": "Allow",
    "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetObjectVersion"
    ],
    "Resource": "arn:aws:s3:::tyderia-foodtruck-bucket-*/*"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
    role       = aws_iam_role.iam_for_lambda.name
    policy_arn = aws_iam_policy.lambda_access.arn
}

