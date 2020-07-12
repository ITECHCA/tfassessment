# locals {
#   max_subnet_length = max(
#     length(var.private_subnets),
#     length(var.database_subnets)
#   )
#   nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
# }

resource "aws_route" "public_internet_gateway" {
  count = var.create && var.resource_create && var.create_igw && length(var.subnet_id) > 0 ? 1 : 0

  route_table_id         = element(var.rt_id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(var.igw_id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "instance_id" {
  count = var.create && var.resource_create && var.create_instance_id && length(var.instance_id) > 0 ? 1 : 0

  route_table_id         = element(var.rt_id, count.index)
  destination_cidr_block = var.destination_cidr_block
  instance_id             = element(var.instance_id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "nat_gateway" {
  count = var.create && var.resource_create && var.create_ngw && length(var.nat_gw_id) > 0 ? length(var.rt_id) : 0

  route_table_id         = element(var.rt_id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = element(var.nat_gw_id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "transit_gateway" {
  count = var.create && var.resource_create && var.create_tgw && length(var.transit_gw_id) > 0 ? length(var.rt_id) : 0

  route_table_id         = element(var.rt_id, count.index)
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id             = element(var.transit_gw_id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "vpc_peering" {
  count = var.create && var.resource_create && var.create_peering && length(var.peering_id) > 0 ? length(var.rt_id) : 0

  route_table_id         = element(var.rt_id, count.index)
  destination_cidr_block = var.destination_cidr_block
  vpc_peering_connection_id             = element(var.peering_id, count.index)

  timeouts {
    create = "5m"
  }
}