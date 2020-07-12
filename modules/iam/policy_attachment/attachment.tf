resource "aws_iam_role_policy_attachment" "roleattach" {
  count = var.create && var.resource_create && length(var.roles) > 0 ? length(var.policy_arn) : 0
  #users      = ["${aws_iam_user.user.name}"]
  role     = element(var.roles, count.index)
  policy_arn = element(concat(var.policy_arn, list("")), count.index)
}

resource "aws_iam_user_policy_attachment" "userattach" {
  count = var.create && var.resource_create && length(var.users) > 0 ? length(var.users) : 0
  user      = element(var.users, count.index)
  #roles      = ["${aws_iam_role.role.name}"]
  policy_arn = element(concat(var.policy_arn, list("")), count.index)
}

resource "aws_iam_group_policy_attachment" "groupattach" {
  count = var.create && var.resource_create && length(var.groups) > 0 ? length(var.groups) : 0
  #users      = [var.users]
  group     = element(var.groups, count.index)
  #roles      = ["${aws_iam_role.role.name}"]
  policy_arn = element(concat(var.policy_arn, list("")), count.index)
}

# resource "aws_iam_policy_attachment" "roleattach" {
#   count = var.create && var.resource_create && length(var.roles) > 0 ? length(var.roles) : 0
#   name       = format("%s-%s", var.name, count.index + 1)
#   #users      = ["${aws_iam_user.user.name}"]
#   roles      = var.roles
#   policy_arn = element(var.policy_arn, count.index)
# }