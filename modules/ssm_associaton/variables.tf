variable "instance_id" {
  description = "A list of igw ids in the region"
  type        = list(string)
  default     = []
}

variable "resource_create" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type = bool
  default = false
}

variable "create" {
  default = false
  type = bool
  description = "Master control variable if VPC should be created (it affects almost all resources)"
}

variable "doc_name" {
    default = "AWS-ApplyAnsiblePlaybooks"
}

variable "s3_key_prefix" {
  default = "logs"
}

# variable "path" {
#   default = ""
# }

variable "s3_bucket_name" {
  default = []
}

variable "parameters" {}