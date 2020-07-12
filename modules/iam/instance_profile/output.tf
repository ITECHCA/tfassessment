output "instance_profile_name" {
    value = aws_iam_instance_profile.ec2_profile.*.name
}

output "instance_profile_arn" {
    value = aws_iam_instance_profile.ec2_profile.*.arn
}

output "instance_profile_id" {
    value = aws_iam_instance_profile.ec2_profile.*.id
}