output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc[*].id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.vpc[*].arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc[*].cidr_block
}