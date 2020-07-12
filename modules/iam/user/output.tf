output "userarn" {
    value = aws_iam_user.user.*.arn
}

output "userpath" {
    value = aws_iam_user.user.*.path
}

output "user_id" {
    value = aws_iam_user.user.*.user_id
}

output "user_name" {
    value = aws_iam_user.user.*.user_name
}