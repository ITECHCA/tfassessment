variable "resource_create" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default = false
}

variable "create" {
  default = false
  description = "Master control variable if VPC should be created (it affects almost all resources)"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "A list of database subnets"
  type        = list(string)
  default     = []
}

# variable "enable_nat_gateway" {
#   description = "Should be true if you want to provision NAT Gateways for each of your private networks"
#   type        = bool
#   default     = false
# }

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = false
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Should be false if you do not want to auto-assign public IP on launch"
  type        = bool
  default     = false
}

variable "subnet_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}

# variable "private_subnet_suffix" {
#   description = "Suffix to append to private subnets name"
#   type        = string
#   default     = "private"
#}

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
