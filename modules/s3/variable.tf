variable "bucket_prefix" {}

variable "s3_bucket_force_destroy" {
    default = true
}

variable "kms_arn" {
    default = ""
}

variable "resource_create" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default = false
}

variable "create" {
  default = false
  description = "Master control variable if VPC should be created (it affects almost all resources)"
}

variable "tags" {
    type = map
    default = {}
}

variable "versioning" {
  default = false
}

variable "policy" {
  type = string
  default = ""
}

variable "sse_algorithm" {
  default = "aws:kms"
}