#------------------Task 1 settings-----------------------------#
task1 = "false"
env = "devops"
region = "ap-southeast-1"
cidr = "10.1.0.0/24"
name = "vpc"
single_nat_gateway = "true"
public_subnets = ["10.1.0.0/28", "10.1.0.16/28", "10.1.0.32/28"]
private_subnets = ["10.1.0.64/28", "10.1.0.80/28", "10.1.0.96/28"]
database_subnets = ["10.1.0.112/28", "10.1.0.128/28", "10.1.0.144/28"]
instance_count = 1
instance_type = "t2.micro"
upload_directory = "ansible-config"
profile = "tfassesment"
