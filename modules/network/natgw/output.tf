output "nat_alloc_id" {
    value = aws_nat_gateway.natgw.*.allocation_id
}

output "nat_id" {
    value = aws_nat_gateway.natgw.*.id
}

output "nat_private_ip" {
    value = aws_nat_gateway.natgw.*.private_ip
}

output "nat_public_ip" {
    value = aws_nat_gateway.natgw.*.public_ip
}