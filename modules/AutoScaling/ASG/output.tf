output "asgname" {
    value = aws_autoscaling_group.asg.*.name
}

output "asgid" {
    value = aws_autoscaling_group.asg.*.id
}

output "asgarn" {
    value = aws_autoscaling_group.asg.*.arn
}

output "asglb" {
    value = aws_autoscaling_group.asg.*.load_balancers
}