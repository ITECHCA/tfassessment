output "launchconfiguration" {
  value = aws_launch_configuration.lc.*.id
}

output "launchconfigurationarn" {
  value = aws_launch_configuration.lc.*.arn
}

output "launchconfigurationname" {
  value = aws_launch_configuration.lc.*.name
}
