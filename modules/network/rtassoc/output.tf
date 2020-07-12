output "subnet_rt_association_id" {
    value = aws_route_table_association.subnet_rtassoc.*.id
}

output "gateway_rt_association_id" {
    value = aws_route_table_association.gateway_rtassoc.*.id
}