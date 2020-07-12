resource "random_password" "password" {
  count = var.create && var.resource_create ? 1 : 0
  length = 16
  special = false
  override_special = "%@"
}

resource "random_string" "random" {
  count = var.create && var.resource_create ? 1 : 0
  length = 8
  special = false
  override_special = "/_+=.@-"
}

resource "aws_kms_key" "secretmanager_key" {
  count = var.create && var.resource_create ? 1 : 0
  description             = "KMS key for Secret manager"
  deletion_window_in_days = 10
}

resource "aws_secretsmanager_secret" "secret" {
  count = var.create && var.resource_create ? 1 : 0
  kms_key_id = element(concat(aws_kms_key.secretmanager_key.*.key_id, list("")), count.index)
  name       = format("%s%s%s%s", var.name, element(concat(random_string.random.*.result, list("")), count.index), "0", count.index + 1)
  tags =  merge(
    {
      "Name" = format("%s%s%s%s", var.name, element(concat(random_string.random.*.result, list("")), count.index), "0", count.index + 1)
    },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "secret" {
  count = var.create && var.resource_create ? 1 : 0
  secret_id     = element(concat(aws_secretsmanager_secret.secret.*.id, list("")), count.index)
  secret_string = element(concat(random_password.password.*.result, list("")), count.index)
}