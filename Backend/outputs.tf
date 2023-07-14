
output "api_endpoint_url" {
  value = "${aws_api_gateway_stage.VC-API-PRODUCTION-STAGE.invoke_url}${aws_api_gateway_resource.VC-API-METHODS.path}"
}

