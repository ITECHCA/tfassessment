resource "aws_eip_association" "eip_assoc" {
  count = var.create && var.resource_create && var.instance_association ? var.assoc_count : 0
  instance_id   = var.instance_association ? element(var.instance_id, count.index): null
  allocation_id = element(var.allocation_id, count.index)
}