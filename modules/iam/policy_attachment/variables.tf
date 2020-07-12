variable "name" {
  description = "The name of the policy"
  type        = string
  default     = ""
}

variable "resource_create" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default = false
}

variable "create" {
  default = false
  description = "Master control variable if VPC should be created (it affects almost all resources)"
}

variable "roles" {
  description = "A list of role inside the VPC"
  type        = list(string)
  default     = []
}

variable "users" {
  description = "A list of users inside the VPC"
  type        = list(string)
  default     = []
}

variable "groups" {
  description = "A list of groups inside the VPC"
  type        = list(string)
  default     = []
}

variable "policy_arn" {
  description = "A list of arn inside the VPC"
  type        = list(string)
  default     = []
}