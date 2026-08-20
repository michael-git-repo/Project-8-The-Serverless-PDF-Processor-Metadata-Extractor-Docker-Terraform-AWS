# Lambda Function
resource "aws_lambda_function" "processor" {
  function_name = "${var.project_name}-function"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.app_repo.repository_url}:latest"
  timeout       = 30
  memory_size   = 512

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.pdf_metadata_table.name
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attach]
}

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.pdf_upload_bucket.arn
}

# Bucket Notification Trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.pdf_upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".pdf"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}