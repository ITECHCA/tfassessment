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

variable "eip_count" {
  description = "Number of eip to launch"
  type        = number
  default     = 0
}

variable "name" {
  description = "EIP name."
  type        = string
  default     = ""
}