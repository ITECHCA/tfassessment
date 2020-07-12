output "role_arn" {
    value = aws_iam_role.instance_role.*.arn
}

output "role_id" {
    value = aws_iam_role.instance_role.*.id
}

output "role_name" {
    value = aws_iam_role.instance_role.*.name
}