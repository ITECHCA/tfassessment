resource "aws_nat_gateway" "natgw" {
  count = var.create && var.resource_create && var.create_ngw ? var.gateway_count : 0

  allocation_id = element(
    var.allocation_id,
    count.index,
  )
  subnet_id = element(
    var.subnet_id,
    count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        count.index + 1
      )
    },
    var.tags
  )
}