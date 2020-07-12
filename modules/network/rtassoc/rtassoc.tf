resource "aws_route_table_association" "subnet_rtassoc" {
  count = var.create && var.resource_create && length(var.subnet_id) > 0 ? length(var.subnet_id) : 0

  subnet_id      = element(var.subnet_id, count.index)
  route_table_id = element(var.rt_id, count.index)
}

resource "aws_route_table_association" "gateway_rtassoc" {
  count = var.create && var.resource_create && length(var.gateway_id) > 0 ? length(var.subnet_id) : 0

  gateway_id      = element(var.gateway_id, count.index)
  route_table_id = element(var.rt_id, count.index)
}