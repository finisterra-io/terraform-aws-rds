output "id" {
  description = "The db option group id"
  value       = try(aws_db_option_group.this[0].id, null)
}

output "arn" {
  description = "The ARN of the db option group"
  value       = try(aws_db_option_group.this[0].arn, null)
}
