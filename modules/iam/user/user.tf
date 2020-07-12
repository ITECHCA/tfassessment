resource "aws_iam_user" "user" {
  count = var.count
  name = var.name
}