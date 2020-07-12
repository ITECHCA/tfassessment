output "eip_id" {
    value = aws_eip.eip.*.id
}

output "eip_privateip" {
    value = aws_eip.eip.*.private_ip
}

output "eip_privatedns" {
    value = aws_eip.eip.*.private_dns
}

output "eip_publicip" {
    value = aws_eip.eip.*.public_ip
}

output "eip_publicdns" {
    value = aws_eip.eip.*.public_dns
}

output "eip_poolid" {
    value = aws_eip.eip.*.public_ipv4_pool
}