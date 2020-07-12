resource "aws_iam_policy" "policy" {
  count = var.create && var.resource_create ? 1 : 0
  name        = format("%s-%s", var.name, count.index + 1)
  path        = var.path
  description = var.description

  policy = var.policy
}