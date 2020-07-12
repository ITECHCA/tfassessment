resource "aws_instance" "ec2" {
  count = var.create && var.resource_create ? var.instance_count : 0
  ami              = var.ami
  instance_type    = var.instance_type
  user_data        = var.user_data
  subnet_id      =  element(var.subnet_ids, count.index)
  key_name               = element(var.key_name, count.index)
  monitoring             = var.monitoring
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile

  associate_public_ip_address = var.associate_public_ip_address


  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
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
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", null)
    }
  }
  # lifecycle {
  #   ignore_changes = [user_data]
  # }

  # dynamic "ephemeral_block_device" {
  #   for_each = var.ephemeral_block_device
  #   content {
  #     device_name  = ephemeral_block_device.value.device_name
  #     no_device    = lookup(ephemeral_block_device.value, "no_device", null)
  #     virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
  #   }
  # }

  dynamic "network_interface" {
    for_each = var.network_interface
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }

  tags = merge(
    {
      "Name" = format("%s-%s", var.name, count.index + 1)
    },
    var.tags
  )

  volume_tags = merge(
    {
      "Name" = format("%s-%s-%s", var.name, "vol", count.index + 1)
    },
    var.tags
  )

}

# Prepare shell script
# data "template_file" "shell_script" {
#   count = var.create && var.resource_create && var.mysql_bake_instance ? 1 : 0
#   template = {var.shell_script

#   vars {
#     DATABASE_ENDPOINT = var.endpoint
#     DATABASE_PORT     = var.port
#     DATABASE_NAME     = var.database
#     DATABASE_USER     = var.master_username
#     DATABASE_PASSWORD = var.master_password
#   }
# }

# # Prepare MySQL script
# data "template_file" "mysql_script" {
#   count = var.create && var.resource_create && var.mysql_bake_instance ? 1 : 0
#   template = "${var.sql_script}"

#   vars {
#     DATABASE_NAME     = "${var.database}"
#   }
# }

# # Bootstrap script
# data "template_file" "user_data" {
#   count = var.create && var.resource_create && var.mysql_bake_instance ? 1 : 0
#   template = "${file("${path.root}/../scripts/bake_script.sh.tpl")}"

#   vars {
#     DATABASE_ENDPOINT = "${var.endpoint}"
#     DATABASE_PORT     = "${var.port}"
#     DATABASE_NAME     = "${var.database}"
#     DATABASE_USER     = "${var.master_username}"
#     DATABASE_PASSWORD = "${var.master_password}"
#     MYSQL_SCRIPT      = "${data.template_file.mysql_script.rendered}"
#     SHELL_SCRIPT      = "${data.template_file.shell_script.rendered}"
#   }
# }

# resource "aws_instance" "ephemeral_instance" {
#   count = var.create && var.resource_create && var.mysql_bake_instance ? 1 : 0
#   subnet_id              = "${var.subnet_id}"
#   instance_type          = "${var.instance_type}"
#   iam_instance_profile   = "${var.iam_instance_profile}"
#   ami                    = "${data.aws_ami.ephemeral_instance_ami.id}"
#   vpc_security_group_ids = ["${var.security_group_ids}"]
#   user_data              = "${data.template_file.user_data.rendered}"
#   tags                   = "${map("Name", format("%s-RDS_BOOSTRAP_EPHEMERAL_INSTANCE", var.name))}"

#   # Terminate instance on shutdown
#   instance_initiated_shutdown_behavior = "terminate"

#   root_block_device {
#     volume_type           = "gp2"
#     volume_size           = "128"
#     delete_on_termination = "true"
#   }

#   volume_tags = "${map("Name", format("%s-RDS_BOOSTRAP_EPHEMERAL_INSTANCE", var.name))}"

# }