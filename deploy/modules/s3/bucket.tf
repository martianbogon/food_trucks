resource "aws_s3_bucket" "data_bucket" {
  bucket_prefix = "tyderia-foodtruck-bucket-"
  force_destroy = true

  tags = {
    Name        = "foodtruck-demo-data-bucket"
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "private_bucket_acl" {
  bucket = aws_s3_bucket.data_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "data_bucket_public_access" {
  bucket = aws_s3_bucket.data_bucket.id

  block_public_acls   = true
  block_public_policy = true
}

