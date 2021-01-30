resource "aws_iam_role" "edge_lambda_role" {
  name = "lambda-edge-role-${var.name}"

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

resource "aws_iam_role_policy" "test_policy" {
  name = "lambda-edge-invoke-policy-${var.name}"
  role = aws_iam_role.edge_lambda_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "${aws_lambda_function.vpc_lambda.arn}"
      }
    ]
  }
  EOF
}



data "archive_file" "edge_lambda" {
  type        = "zip"
  source_file = "lambda/edge.js"
  output_path = "lambda/edge-lambda.zip"
}

resource "aws_lambda_function" "edge_lambda" {
  filename      = "lambda/edge-lambda.zip"
  function_name = "app-edge-function-${var.name}"
  role          = aws_iam_role.edge_lambda_role.arn
  handler       = "edge.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = data.archive_file.edge_lambda.output_base64sha256

  runtime = "nodejs12.x"
}