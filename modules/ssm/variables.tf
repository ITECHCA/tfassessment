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

variable "name" {
    default = "default name"
}

variable "description" {
    default = "default desc"
}

variable "type" {
    default = "SecureString"
}

variable "value" {
    default = "samplevalue"
}

variable "key_id" {
    default = ""
    description = "Encryption key"
}

variable "overwrite" {
  type        = bool
  default = true
  description = "overwrite existing param"
}

variable "env" {
    default = "dev"
}