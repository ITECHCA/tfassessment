variable "region" {
  default = "ap-southeast-1"
}

variable "create" {
  description = "A master control variable to control resource creation"
  default     = "false"
}

variable "dynamodb_table_billing_mode" {
  default = "PAY_PER_REQUEST"
}

variable "dynamodb_table_name" {
  default = "remote-state-lock"
}

variable "tags" {
  type = map
  default = {
    "Terraform" : "true"
  }
}

variable "state_bucket_prefix" {
  description = "Creates a unique state bucket name beginning with the specified prefix."
  default     = "tf-remote-state"
}

variable "state_bucket_force_destroy" {
  description = "A boolean that indicates all objects should be deleted from S3 buckets so that the buckets can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "env" {
    default = "dev"
}

variable "task1" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default = "false"
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR"
  type        = string
  default     = "10.0.0.0/16"
}


variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "dev"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  type        = bool
  default     = false
}

variable "public_subnets" {
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  type        = list(string)
  default     = []
}

variable "public_ingress_rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = list(string)
  default = ["http-80-tcp", "ssh-tcp", "http-8080-tcp", "mysql-tcp"]
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 0
}

variable "instance_type" {
    description = "Instance type"
    default = "t2.micro"
}

variable "upload_directory" {
  default = "path.module"
}

variable "create_ngw" {
  type        = bool
  default     = false
}

variable "profile" {
  default = "tfassesment"
}

variable "task2" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default = "false"
}