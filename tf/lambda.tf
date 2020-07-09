resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "authenticator_lambda" {
  filename      = "../${var.lambda_zip}"
  function_name = var.lambda_handler
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = var.lambda_handler

  source_code_hash = "${filebase64sha256("../${var.lambda_zip}")}"
  runtime          = "go1.x"
  memory_size      = 3008
  environment {
    variables = {
      FAUNADB_SECRET           = var.fauna_secret
      FIREBASE_SECRET_LOCATION = "./${var.firebase_cred_file}"
    }
  }
}
