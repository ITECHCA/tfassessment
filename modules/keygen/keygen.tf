resource "tls_private_key" "key" {
  count = var.create && var.resource_create ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}