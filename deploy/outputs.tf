output "bucket" {
  description = "Bucket name created"
  value       = module.s3.bucket
}

output "bucket_regional_domain_name" {
  description = "Domain name of bucket"
  value       = module.s3.bucket_regional_domain_name
}
