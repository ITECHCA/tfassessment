output "secret_manager_id" {
    value = aws_secretsmanager_secret.secret.*.id
}

output "secret_manager_arn" {
    value = aws_secretsmanager_secret.secret.*.arn
}

output "secret_id" {
    value = aws_secretsmanager_secret_version.secret.*.id
}

output "secret_arn" {
    value = aws_secretsmanager_secret_version.secret.*.arn
}

output "secret_version" {
    value = aws_secretsmanager_secret_version.secret.*.version_id
}

output "db_pass" {
    value = element(concat(random_password.password.*.result, list("")), 0)
}

output "secret_name" {
    value = aws_secretsmanager_secret.secret.*.name
}