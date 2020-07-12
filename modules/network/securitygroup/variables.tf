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

variable "tags" {
    type = map
    default = {}
}

variable "vpc_id" {
  default = ""
}

variable "env" {
    default = "dev"
}

variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "description" {
  description = "SG description"
  type        = string
  default     = ""
}

variable "revoke_rules_on_delete" {
  type        = bool
  default     = false
}