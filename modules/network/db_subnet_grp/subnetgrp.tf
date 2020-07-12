resource "aws_db_subnet_group" "DBGroup" {
  count = var.create && var.resource_create ? 1 : 0
  name       = format("%s-%s%s", var.name, "0", count.index + 1)
  subnet_ids = var.subnet_ids
  description = var.description

  tags =  merge(
    {
      "Name" = format("%s-%s%s", var.name, "0", count.index + 1)
    },
    var.tags
  )
}