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

variable "assoc_count" {
  description = "Number of eip to associate"
  type        = number
  default     = 0
}

variable "instance_association" {
  type        = bool
  default = false
}

variable "instance_id" {
    default = []
    type    = list(string)
}

variable "allocation_id" {
    default = []
    type    = list(string)
}