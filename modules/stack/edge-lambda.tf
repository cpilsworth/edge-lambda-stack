data "archive_file" "edge_lambda" {
  type        = "zip"
  source_file = "lambda/edge.js"
  output_path = "lambda/edge-lambda.zip"
}

resource "aws_lambda_function" "edge_lambda" {
  function_name    = "app-edge-function-${var.name}"
  role             = aws_iam_role.edge_lambda_role.arn
  handler          = "edge.handler"
  filename         = "lambda/edge-lambda.zip"
  source_code_hash = data.archive_file.edge_lambda.output_base64sha256

  runtime = "nodejs12.x"
}

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
