resource aws_db_instance "mysqldb" {
  count = var.create && var.resource_create ? 1 : 0
  allocated_storage    = var.alloc_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_subnet_group_name = element(concat(var.subnet_group, list("")), count.index)
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  publicly_accessible  = var.public
  vpc_security_group_ids  = var.security_group
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  storage_encrypted = var.instance_class != "db.t2.micro" && var.storage_encrypted ? var.storage_encrypted : false
  multi_az = var.multi_az
  kms_key_id        = var.instance_class != "db.t2.micro" && var.storage_encrypted ? var.kms_arn : null
  availability_zone    = var.multi_az ? null : var.AZ
  identifier           = lower(var.identifier)
  name                 = var.dbname
  username             = var.dbuser
  password             = var.dbpassword
  parameter_group_name = element(concat(aws_db_parameter_group.default.*.id, list("")), count.index)
  skip_final_snapshot  = var.snapshot
  tags =  merge(
    {
      "Name" = format("%s-%s%s", var.dbname, "0", count.index + 1)
    },
    var.tags
  )
}

resource "aws_db_parameter_group" "default" {
  count = var.create && var.resource_create ? 1 : 0
  name   = "rds-pg"
  family = format("%s%s", var.engine, var.engine_version)

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  parameter {
    name = "log_bin_trust_function_creators"
    value = "1"
  }
}


# provider "mysql" {
#   endpoint = try(aws_db_instance.mysqldb[0].endpoint, null)
#   username = try(aws_db_instance.mysqldb[0].username, null)
#   password = try(aws_db_instance.mysqldb[0].password, null)
# }

# resource "mysql_database" "app" {
#   count = var.create && var.resource_create ? 1 : 0
#   name = var.databasename
# }