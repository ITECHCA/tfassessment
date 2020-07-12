resource "aws_autoscaling_group" "asg" {
  count = var.create && var.resource_create ? 1 : 0

  name = format("%s-%s", var.name, count.index + 1)
  launch_configuration = element(concat(var.launch_configuration, list("")), count.index)
  vpc_zone_identifier  = var.vpc_zone_identifier
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity

  load_balancers            = var.load_balancers
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  min_elb_capacity          = var.min_elb_capacity
  wait_for_elb_capacity     = var.wait_for_elb_capacity
  target_group_arns         = var.target_group_arns
  default_cooldown          = var.default_cooldown
  force_delete              = var.force_delete
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group           = var.placement_group
  enabled_metrics           = var.enabled_metrics
  metrics_granularity       = var.metrics_granularity
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in     = var.protect_from_scale_in
  service_linked_role_arn   = var.service_linked_role_arn
  max_instance_lifetime     = var.max_instance_lifetime

  tag {
    key                 = "Name"
    value               = format("%s-%s", var.name, count.index + 1)
    propagate_at_launch = true
  }
  timeouts {
    delete = "15m"
  }
  tag {
    key                 = "Workspace"
    value               = terraform.workspace
    propagate_at_launch = true
  }  
  dynamic "tag" {
    for_each = var.tags_as_map

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}