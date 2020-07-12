variable "rules" {
  description = "Map of known security group rules (define as 'name' = ['from port', 'to port', 'protocol', 'description'])"
  type        = map(list(any))
  default = {
    # HTTP  rules
    http-80-tcp   = [80, 80, "tcp", "HTTP Traffic"]
    http-8080-tcp = [8080, 8080, "tcp", "HTTP Traffic"]
    # HTTPS
    https-443-tcp  = [443, 443, "tcp", "HTTPS Traffic"]
    https-8443-tcp = [8443, 8443, "tcp", "HTTPS Traffic"]
    # SSH rules
    ssh-tcp = [22, 22, "tcp", "SSH Traffic"]
    # MySQL
    mysql-tcp = [3306, 3306, "tcp", "MySQL/Aurora Traffic"]
    # Open all ports & protocols
    all-all       = [-1, -1, "-1", "All protocols"]
    all-tcp       = [0, 65535, "tcp", "All TCP ports"]
    all-udp       = [0, 65535, "udp", "All UDP ports"]
    all-icmp      = [-1, -1, "icmp", "All IPV4 ICMP"]
    all-ipv6-icmp = [-1, -1, 58, "All IPV6 ICMP"]
    custom-rule-tcp = [5000, 5000, "tcp", "Application Traffic"]
    # This is a fallback rule to pass to lookup() as default. It does not open anything, because it should never be used.
    _ = ["", "", ""]
  }
}

##########
# Ingress
##########
variable "ingress_rules" {
  description = "List of ingress rules to create by name"
  type        = list(string)
  default     = []
}

variable "type" {
  description = "Rule type ingress or egress"
  type        = string
  default     = "egress"
}

variable "sg_id" {
  description = "Security group"
  type        = list(string)
  default     = []
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

variable "cidr_blocks" {
  description = "Security group"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "source_security_group_id" {
  description = "Security group"
  type        = list(string)
  default = []
}