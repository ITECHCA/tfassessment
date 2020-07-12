resource "aws_eip" "eip" {
  count = var.create && var.resource_create ? var.eip_count : 0
  vpc = true
  tags = merge(
    {
      "Name" = format("%s-%s", var.name, count.index + 1)
    },
    var.tags
  )

}