resource "aws_iam_role" "instance_role" {
  count = var.create && var.resource_create ? 1 : 0
  name = format("%s-%s", var.name, count.index + 1)
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}