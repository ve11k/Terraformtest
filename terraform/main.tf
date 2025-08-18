provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "mainforfiles" {
  bucket = "mainforfiles"
}

resource "aws_s3_bucket" "bucket2forzvit" {
  bucket = "bucket2forzvit"
}
resource "aws_s3_object" "zvit_folder" {
  bucket = aws_s3_bucket.bucket2forzvit.bucket
  key    = "zvit/"
}
resource "aws_s3_object" "forecast_folder" {
  bucket = aws_s3_bucket.bucket2forzvit.bucket
  key    = "forecast/"
}

resource "aws_s3_bucket" "bucket3forforecast" {
  bucket = "bucket3forforecast"
}
resource "aws_s3_object" "other_folder" {
  bucket = aws_s3_bucket.bucket3forforecast.bucket
  key    = "other/"

}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-s3-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:CopyObject"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "put_only_policy" {
  name        = "S3PutOnlyPolicy"
  description = "Allow only PutObject to a specific bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPutOnly",
        Effect = "Allow",
        Action = ["s3:PutObject","s3:ListBucket"]
        Resource = ["arn:aws:s3:::mainforfiles/*",
                    "arn:aws:s3:::mainforfiles"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "put_external_policy" {

 bucket = aws_s3_bucket.mainforfiles.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowExternalAccountPut",
        Effect: "Allow",
        Principal: {
          AWS = var.external_account_arn
        },
        Action: [
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource: [
          "arn:aws:s3:::mainforfiles",
          "arn:aws:s3:::mainforfiles/*"
        ]
      }
    ]
  })
}



resource "aws_iam_user_policy_attachment" "attach_put_only" {
  user       = "Oleksandrrole"
  policy_arn = aws_iam_policy.put_only_policy.arn
}
resource "aws_iam_user" "external_user_oleksandr" {
  name = "external_put_Oleksandr"
}
resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.external_user_oleksandr.name
  policy_arn = aws_iam_policy.put_only_policy.arn
}



data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "file_router" {
  function_name = "file-router-fn"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 10

  environment {
    variables = {
      ZVIT_BUCKET = aws_s3_bucket.bucket2forzvit.bucket
      FORECAST_BUCKET   = aws_s3_bucket.bucket3forforecast.bucket
    }
  }
}

resource "aws_s3_bucket_notification" "trigger_lambda" {
  bucket = aws_s3_bucket.mainforfiles.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.file_router.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_router.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.mainforfiles.arn
}

variable "external_account_arn" {
  description = "ARN зовнішнього AWS акаунта"
  type        = string
}