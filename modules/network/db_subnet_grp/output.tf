output "db_subnetgrp_name" {
  value = aws_db_subnet_group.DBGroup.*.id
}

output "db_subnetgrp_arn" {
  value = aws_db_subnet_group.DBGroup.*.arn
}