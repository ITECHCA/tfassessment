resource "aws_key_pair" "key_pair" {
  count = var.create && var.resource_create ? 1 : 0
  key_name   = format("%s-%s", var.key_name, count.index + 1)
  public_key = element(var.public_key, count.index)
  tags = merge(
    var.tags,
    {
      "Environment" = format("%s", var.env)
    }
  )
}