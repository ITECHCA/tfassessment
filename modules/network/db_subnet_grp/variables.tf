variable "tags" {
    type = map
    default = {}
}

variable "resource_create" {
  type        = bool
  description = "Controls if VPC should be created (it affects almost all resources)"
  default = false
}

variable "create" {
  type        = bool
  default = false
  description = "Master control variable if VPC should be created (it affects almost all resources)"
}

variable "name" {
  description = "EIP name."
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "Description for your subnet group"
  default = "Managed by Terraform"
  type        = string
}