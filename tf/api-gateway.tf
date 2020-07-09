resource "aws_api_gateway_resource" "authenticator" {
  rest_api_id = "${aws_api_gateway_rest_api.authenticator.id}"
  parent_id   = "${aws_api_gateway_rest_api.authenticator.root_resource_id}"
  path_part   = "authenticator"
}

resource "aws_api_gateway_rest_api" "authenticator" {
  name = "authenticator"
}

#           POST
# Internet -----> API Gateway
resource "aws_api_gateway_method" "authenticator" {
  rest_api_id   = "${aws_api_gateway_rest_api.authenticator.id}"
  resource_id   = "${aws_api_gateway_resource.authenticator.id}"
  http_method   = "POST"
  authorization = "NONE"
}

#              POST
# API Gateway ------> Lambda
# For Lambda the method is always POST and the type is always AWS_PROXY.
#
# The date 2015-03-31 in the URI is just the version of AWS Lambda.
resource "aws_api_gateway_integration" "authenticator" {
  rest_api_id             = "${aws_api_gateway_rest_api.authenticator.id}"
  resource_id             = "${aws_api_gateway_resource.authenticator.id}"
  http_method             = "${aws_api_gateway_method.authenticator.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.authenticator_lambda.arn}/invocations"
}

# This resource defines the URL of the API Gateway.
resource "aws_api_gateway_deployment" "authenticator_v1" {
  depends_on = [
    "aws_api_gateway_integration.authenticator"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.authenticator.id}"
  stage_name  = "v1"
}
