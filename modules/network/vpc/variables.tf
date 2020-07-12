variable "resource_create" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default = false
}

variable "create" {
  default = false
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR"
  type        = string
  default     = "10.0.0.0/16"
}


variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "env" {
    default = "dev"
}

variable "tags" {
    type = map
    default = {}
}