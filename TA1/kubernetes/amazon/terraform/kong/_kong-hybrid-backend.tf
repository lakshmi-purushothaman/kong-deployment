terraform {
  backend "s3" {
    key            = "kong-hybrid.tf"
    region         = "eu-west-2"
    bucket         = "tf-hybrid-kong-bucket"
    dynamodb_table = "hybrid-kong-terraform-state-locking"
    encrypt        = true # Optional, S3 Bucket Server Side Encryption
  }
}
