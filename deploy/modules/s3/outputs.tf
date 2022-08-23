output "bucket" {
  description = "Bucket name created"
  value = aws_s3_bucket.data_bucket.bucket
}

output "bucket_regional_domain_name" {
  description = "Domain name of bucket"
  value = aws_s3_bucket.data_bucket.bucket_regional_domain_name
}
