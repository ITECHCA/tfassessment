variable "resource_create" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default = false
}

variable "create" {
  default = false
  description = "Master control variable if VPC should be created (it affects almost all resources)"
}

variable "subnet_id" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "allocation_id" {
  description = "A list of public IP inside the VPC"
  type        = list(string)
  default     = []
}


variable "create_ngw" {
  default = false
  description = "Master control variable if NGW shd be created"
}

variable "name" {
  description = "NGW name."
  type        = string
  default     = ""
}

variable "gateway_count" {
    default = 0
}

variable "tags" {
    type = map
    default = {}
}