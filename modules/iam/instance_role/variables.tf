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


variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "tags" {
    type = map
    default = {}
}