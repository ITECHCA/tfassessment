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

variable "key_name" {
    default = "keypair"
}

variable "public_key" {
    default = []
    type    = list(string)
}

variable "env" {
    default = "dev"
}

variable "tags" {
    type = map
    default = {}
}
