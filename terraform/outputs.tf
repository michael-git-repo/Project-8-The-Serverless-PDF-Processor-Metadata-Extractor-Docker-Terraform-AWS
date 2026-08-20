output "s3_bucket_name" {
  value       = aws_s3_bucket.pdf_upload_bucket.id
  description = "Bucket name for PDF uploads"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.pdf_metadata_table.name
  description = "DynamoDB metadata table name"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.app_repo.repository_url
  description = "ECR Repository URL for Docker images"
}