output "ssm_arn" {
    value = aws_ssm_parameter.secret.*.arn
}

output "ssm_name" {
    value = aws_ssm_parameter.secret.*.name
}

output "ssm_type" {
    value = aws_ssm_parameter.secret.*.type
}

output "ssm_value" {
    value = aws_ssm_parameter.secret.*.value
}