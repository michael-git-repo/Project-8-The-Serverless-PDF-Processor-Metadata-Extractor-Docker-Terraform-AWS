# Random suffix to guarantee unique S3 bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket for PDF Uploads
resource "aws_s3_bucket" "pdf_upload_bucket" {
  bucket        = "${var.project_name}-uploads-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

# DynamoDB Table for Extracted Metadata
resource "aws_dynamodb_table" "pdf_metadata_table" {
  name         = "${var.project_name}-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pdf_id"

  attribute {
    name = "pdf_id"
    type = "S"
  }
}