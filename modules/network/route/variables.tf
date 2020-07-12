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

variable "create_igw" {
  description = "Controls if IGW route should be created (it affects almost all resources)"
  type = bool
  default = false
}

variable "rt_id" {
  description = "A list of route table ids in the region"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "A list of subnets ids in the region"
  type        = list(string)
  default     = []
}

variable "igw_id" {
  description = "A list of igw ids in the region"
  type        = list(string)
  default     = []
}

variable "create_instance_id" {
  description = "Controls if Instance ID route should be created"
  type = bool
  default = false
}

variable "instance_id" {
  description = "A list of igw ids in the region"
  type        = list(string)
  default     = []
}

variable "destination_cidr_block" {
    default = "0.0.0.0/0"
    description = "Destination CIDR"
}

variable "create_ngw" {
  description = "Controls if Instance ID route should be created"
  type = bool
  default = false
}

variable "nat_gw_id" {
  description = "A list of igw ids in the region"
  type        = list(string)
  default     = []
}

variable "create_tgw" {
  description = "Controls if transit gateway ID route should be created"
  type = bool
  default = false
}

variable "transit_gw_id" {
  description = "A list of igw ids in the region"
  type        = list(string)
  default     = []
}

variable "create_peering" {
  description = "Controls if peering route should be created"
  type = bool
  default = false
}

variable "peering_id" {
  description = "A list of igw ids in the region"
  type        = list(string)
  default     = []
}