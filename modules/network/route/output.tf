output "public_route_id" {
    value = aws_route.public_internet_gateway.*.id
}

output "instance_id_route_id" {
    value = aws_route.instance_id.*.id
}

output "nat_gateway_route_id" {
    value = aws_route.nat_gateway.*.id
}

output "transit_gateway_route_id" {
    value = aws_route.transit_gateway.*.id
}

output "vpc_peering_route_id" {
    value = aws_route.vpc_peering.*.id
}