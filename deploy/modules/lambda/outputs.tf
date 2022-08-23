output "lambda_function_name" {
  description = "Name of lambda function created"
  value = aws_lambda_function.foodtrucks_lambda.function_name
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of Lambda Function"
  value = aws_lambda_function.foodtrucks_lambda.invoke_arn
}
