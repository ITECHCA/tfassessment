resource "aws_vpc" "vpc" {
  count = var.create && var.resource_create ? 1 : 0
  cidr_block                       = var.cidr
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
 
  tags = merge(
    {
      "Name" = format("%s-%s", var.name, var.env)
      "Environment" = format("%s", var.env)
    },
    var.tags
  )
}