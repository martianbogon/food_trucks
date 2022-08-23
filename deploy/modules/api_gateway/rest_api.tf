resource "aws_api_gateway_rest_api" "rest_api" {
  name = "foodtrucks"
}

resource "aws_api_gateway_resource" "rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "foodtrucks"
}

resource "aws_api_gateway_method" "rest_api_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id               = aws_api_gateway_rest_api.rest_api.id
  resource_id               = aws_api_gateway_resource.rest_api_resource.id
  http_method               = aws_api_gateway_method.rest_api_get_method.http_method
  integration_http_method   = "POST"
  type                      = "AWS_PROXY"
  uri                       = var.lambda_invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_get_method.http_method}${aws_api_gateway_resource.rest_api_resource.path}"
}
