output "key_id" {
    value = aws_key_pair.key_pair.*.id
}

output "keypair_name" {
    value = aws_key_pair.key_pair.*.key_name
}

output "keypair_arn" {
    value = aws_key_pair.key_pair.*.arn
}

output "keypair_id" {
    value = aws_key_pair.key_pair.*.key_pair_id
}