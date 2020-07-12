output "rds_endpoint" {
  value = aws_db_instance.mysqldb.*.endpoint
}

output "rds_arn" {
  value = aws_db_instance.mysqldb.*.arn
}

output "rds_address" {
  value = aws_db_instance.mysqldb.*.address
}

output "rds_id" {
  value = aws_db_instance.mysqldb.*.id
}

output "rds_db_name" {
  value = aws_db_instance.mysqldb.*.name
}

output "rds_resource_id" {
  value = aws_db_instance.mysqldb.*.resource_id
}

output "rds_username" {
  value = aws_db_instance.mysqldb.*.username
}