resource "aws_launch_configuration" "lc" {
  count = var.create && var.resource_create ? 1 : 0
  image_id      = var.ami
  name = format("%s-%s-%s", var.name, "lc", count.index + 1)
  instance_type = var.instance_type
  iam_instance_profile   = var.iam_instance_profile
  security_groups = var.vpc_security_group_ids
  key_name = element(var.key_name, count.index)
  associate_public_ip_address = var.associate_public_ip_address
  user_data = var.user_data
  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      #kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      volume_type           = lookup(root_block_device.value, "volume_type", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", null)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      #kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}