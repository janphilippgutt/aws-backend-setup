output "s3_bucket" {
  value = aws_s3_bucket.tf_state.id
}

output "dynamodb_table" {
  value = aws_dynamodb_table.tf_locks.name
}
