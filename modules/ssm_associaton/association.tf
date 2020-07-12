resource "aws_ssm_association" "example" {
  count = var.create && var.resource_create && length(var.instance_id) > 0 ? length(var.instance_id) : 0
  name = var.doc_name
  targets {
    key    = "InstanceIds"
    values = [element(var.instance_id, count.index)]
  }
  output_location {
    s3_bucket_name = element(var.s3_bucket_name, count.index)
    s3_key_prefix = var.s3_key_prefix
  }
  parameters = var.parameters
}