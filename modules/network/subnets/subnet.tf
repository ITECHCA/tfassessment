################
# Local Variables
################

locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.database_subnets)
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
}

################
# Public subnet
################

resource "aws_subnet" "public" {
  count = var.create && var.resource_create && length(var.public_subnets) > 0 && (false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0

  vpc_id                          = element(var.vpc_id, count.index)
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = element(var.azs, count.index)
  #availability_zone_id            = element(var.azs, count.index)
  map_public_ip_on_launch         = var.map_public_ip_on_launch

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.subnet_suffix,
        count.index + 1
      )
      "zone" =  format("%s", element(var.azs, count.index))
      "Environment" = format("%s", var.env)
    },
    var.tags
  )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = var.create && var.resource_create && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  vpc_id                          = element(var.vpc_id, count.index)
  cidr_block                      = element(concat(var.private_subnets, [""]), count.index)
  availability_zone               = element(var.azs, count.index)

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.subnet_suffix,
        count.index + 1
      )
      "zone" =  format("%s", element(var.azs, count.index))
      "Environment" = format("%s", var.env)
    },
    var.tags
  )
}