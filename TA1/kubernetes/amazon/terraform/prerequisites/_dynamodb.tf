resource "aws_dynamodb_table" "dynamodb-terraform-state-lock-kong-ta2" {
  name = "hybrid-kong-terraform-state-locking"
  hash_key = "LockID"
  read_capacity = 20
  write_capacity = 20
 
  attribute {
    name = "LockID"
    type = "S"
  }
}