resource "aws_iam_role" "vpc_lambda_role" {
   name = "lambda-vpc-role-${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [ 
          "edgelambda.amazonaws.com",
          "lambda.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "vpc_lambda_role" {
  role       = aws_iam_role.vpc_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "vpc_lambda" {
  type        = "zip"
  source_file = "lambda/vpc.js"
  output_path = "lambda/vpc-lambda.zip"
}

resource "aws_lambda_function" "vpc_lambda" {
  filename      = "lambda/vpc-lambda.zip"
  function_name = "app-vpc-function-${var.name}"
  role          = aws_iam_role.vpc_lambda_role.arn
  handler       = "vpc.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = data.archive_file.vpc_lambda.output_base64sha256

  runtime = "nodejs12.x"

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [aws_subnet.main.id]
    security_group_ids = [aws_security_group.allow_tls.id]
  }

}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls-${var.name}"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
