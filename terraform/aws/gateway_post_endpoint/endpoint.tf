resource "aws_api_gateway_method" "endpoint_method" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "endpoint_method_response_200" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.endpoint_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.endpoint_method]
}

resource "aws_api_gateway_method_response" "endpoint_method_response_400" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.endpoint_method.http_method
  status_code = "400"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.endpoint_method]
}

resource "aws_api_gateway_method_response" "endpoint_method_response_403" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.endpoint_method.http_method
  status_code = "403"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.endpoint_method]
}

resource "aws_api_gateway_method_response" "endpoint_method_response_500" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.endpoint_method.http_method
  status_code = "500"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.endpoint_method]
}

resource "aws_api_gateway_integration" "endpoint_integrations" {
  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.endpoint_method.http_method
  integration_http_method = aws_api_gateway_method.endpoint_method.http_method
  type                    = "AWS"
  uri                     = var.uri_arn
  depends_on              = [aws_api_gateway_method.endpoint_method]
}

resource "aws_api_gateway_integration_response" "endpoint_integration_response_400" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.endpoint_method.http_method
  status_code = aws_api_gateway_method_response.endpoint_method_response_400.status_code
  selection_pattern = ".*(unsupported_provider|unspecified|decryption_failure|encryption_failure|bad_request).*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_integration.endpoint_integrations, aws_api_gateway_method_response.endpoint_method_response_400]
}

resource "aws_api_gateway_integration_response" "endpoint_integration_response_403" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.endpoint_method.http_method
  status_code = aws_api_gateway_method_response.endpoint_method_response_403.status_code
  selection_pattern = ".*invalid_credentials.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_integration.endpoint_integrations, aws_api_gateway_method_response.endpoint_method_response_403]
}

resource "aws_api_gateway_integration_response" "endpoint_integration_response_500" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.endpoint_method.http_method
  status_code = aws_api_gateway_method_response.endpoint_method_response_500.status_code
  selection_pattern = ".*internal_server_error.*"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_integration.endpoint_integrations, aws_api_gateway_method_response.endpoint_method_response_500]
}

resource "aws_api_gateway_integration_response" "endpoint_integration_response_200" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = aws_api_gateway_method.endpoint_method.http_method
  status_code = aws_api_gateway_method_response.endpoint_method_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_integration.endpoint_integrations, aws_api_gateway_method_response.endpoint_method_response_200]
}

resource "aws_lambda_permission" "lambda_permissions" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account_number}:${var.rest_api_id}/*"
}
