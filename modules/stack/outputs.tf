output "name" {
  value = var.name
}

output "edge_lambda" {
  value = aws_lambda_function.edge_lambda.arn
}

output "vpc_lambda" {
  value = aws_lambda_function.vpc_lambda.arn
}
