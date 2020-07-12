# variable "kms_key_id" {
#     default = ""
# }

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

variable "name" {
  description = "EIP name."
  type        = string
  default     = ""
}

