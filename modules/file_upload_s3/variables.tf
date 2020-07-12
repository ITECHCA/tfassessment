variable "tags" {
    type = map
    default = {}
}

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

variable "force_destroy" {
  type        = bool
  default = true
  description = "setting object destroy parameter!"
}

variable "encryption_method" {
    type = string
    default = "aws:kms"
    description = "encrypt the objects"
}

variable "bucket_name" {
    type        = string
    default     = ""
    description = "name of the bucket"
}

variable "upload_directory" {
  default = "*"
}

variable "file_name" {
  default = ""
}