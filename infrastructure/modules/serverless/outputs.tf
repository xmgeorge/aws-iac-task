output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.time.function_name
}

output "invoke_url" {
  description = "Public URL for the current-time endpoint"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/time"
}
