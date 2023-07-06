
output "api_endpoint_url" {
  value = "${aws_api_gateway_stage.VC-API-PRODUCTION-STAGE.invoke_url}${aws_api_gateway_resource.VC-API-METHODS.path}"
}

#test gh actions pt2
output "lambda_invoke_arn"{
  value = aws_lambda_function.UPDATE-VISITOR-COUNTER-FUNCTION.invoke_arn
}