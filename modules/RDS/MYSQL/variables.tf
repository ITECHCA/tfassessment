variable "alloc_storage" {
  default = ""
}

variable "storage_type" {
  default = ""
}

variable "engine" {
  default = ""
}

variable "engine_version" {
  default = ""
}

variable "instance_class" {
  default = ""
}

variable "subnet_group" {
  type = list
  default = []
}

variable "public" {
  default = ""
}

variable "security_group" {
  type = list
  default = []
}

variable "AZ" {
  default = ""
}

variable "identifier" {
  default = ""
}

variable "dbname" {
  default = ""
}

variable "dbuser" {
  default = ""
}

variable "dbpassword" {
  default = ""
}

variable "parameter_group" {
  default = ""
}

variable "snapshot" {
  default = ""
}

variable "kms_arn" {
    default = ""
}

variable "resource_create" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  default = false
}

variable "create" {
  default = false
  description = "Master control variable if VPC should be created (it affects almost all resources)"
}

variable "tags" {
    type = map
    default = {}
}

variable "multi_az" {
  description = "multi az deployment"
  default = false
}

variable "storage_encrypted" {
  default = false
}

variable "databasename" {
  default = "CustomerData"
}

variable "iam_database_authentication_enabled" {
  description = "IAM DB Auth"
  default = false
}