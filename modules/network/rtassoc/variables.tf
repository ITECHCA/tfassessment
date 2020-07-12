variable "resource_create" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default = false
}

variable "create" {
  default = false
  description = "Master control variable if VPC should be created (it affects almost all resources)"
}

variable "subnet_id" {
  description = "A list of subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "rt_id" {
  description = "A list of route table ids in the region"
  type        = list(string)
  default     = []
}

variable "gateway_id" {
  description = "A list of gateway ids in the region"
  type        = list(string)
  default     = []
}