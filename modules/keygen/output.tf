output "key_private_pem" {
    value = tls_private_key.key.*.private_key_pem
}

output "key_public_pem" {
    value = tls_private_key.key.*.public_key_pem
}

output "key_public_openssh" {
    value = tls_private_key.key.*.public_key_openssh
}