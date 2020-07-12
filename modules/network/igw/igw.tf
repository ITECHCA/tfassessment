resource "aws_internet_gateway" "igw" {
  count = var.create && var.resource_create && length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = element(var.vpc_id, count.index)
  tags = merge(
    {
      "Name" = format("%s-%s", var.name, count.index + 1)
    },
    var.tags
  )
}