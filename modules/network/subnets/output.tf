output "public_subnet_arn" {
    value = aws_subnet.public.*.arn
}

output "public_subnet_id" {
    value = aws_subnet.public.*.id
}

output "private_subnet_id" {
    value = aws_subnet.private.*.id
}

output "private_subnet_arn" {
    value = aws_subnet.private.*.arn
}