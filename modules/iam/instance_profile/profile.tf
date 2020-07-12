resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.create && var.resource_create ? 1 : 0
  name = var.name
  role = element(var.role, count.index)
}