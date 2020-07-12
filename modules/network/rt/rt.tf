# locals {
#   max_subnet_length = max(
#     length(var.private_subnets),
#     length(var.database_subnets)
#   )
#   nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
# }

resource "aws_route_table" "public" {
  count = var.create && var.resource_create && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = element(var.vpc_id, count.index)

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, count.index + 1)
    },
    var.tags
  )
}

resource "aws_route_table" "private" {
  count = var.create && var.resource_create && length(var.private_subnets) > 0 ? var.gateway_count : 0

  vpc_id = element(var.vpc_id, count.index)

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, element(var.azs, count.index))
    },
    var.tags
  )

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
}