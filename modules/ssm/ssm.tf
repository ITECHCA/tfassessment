resource "aws_ssm_parameter" "secret" {
  count = var.create && var.resource_create ? 1 : 0
  name        = var.name
  description = var.description
  type        = var.type
  overwrite = var.overwrite
  key_id = var.key_id
  value       = element(var.value, count.index)

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-%s", var.name, count.index + 1)
      "Environment" = format("%s", var.env)
    },
  )
}