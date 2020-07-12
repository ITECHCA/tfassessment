output "ec2_id" {
  description = "List of IDs of instances"
  value       = aws_instance.ec2.*.id
}

output "ec2_arn" {
  description = "List of ARNs of instances"
  value       = aws_instance.ec2.*.arn
}

output "ec2_public_dns" {
  description = "List of public DNS names assigned to the instances. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.ec2.*.public_dns
}

output "ec2_private_dns" {
  description = "List of private DNS names assigned to the instances. Can only be used inside the Amazon EC2, and only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.ec2.*.private_dns
}

output "ec2_private_ip" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.ec2.*.private_ip
}

output "vpc_security_group_ids" {
  description = "List of associated security groups of instances, if running in non-default VPC"
  value       = aws_instance.ec2.*.vpc_security_group_ids
}

output "instance_state" {
  description = "List of instance states of instances"
  value       = aws_instance.ec2.*.instance_state
}

output "root_block_device_volume_ids" {
  description = "List of volume IDs of root block devices of instances"
  value       = [for device in aws_instance.ec2.*.root_block_device : device.*.volume_id]
}

output "ebs_block_device_volume_ids" {
  description = "List of volume IDs of EBS block devices of instances"
  value       = [for device in aws_instance.ec2.*.ebs_block_device : device.*.volume_id]
}

output "instance_count" {
  description = "Number of instances to launch specified as argument to this module"
  value       = var.instance_count
}

output "volume_tags" {
  description = "List of tags of volumes of instances"
  value       = aws_instance.ec2.*.volume_tags
}