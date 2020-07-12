# Backend config
# terraform {
#   backend "s3" {
#     shared_credentials_file = "<shared_cred_path>"
#     profile                 = "tfassesment"
#     bucket = "<state_bucket_name>"
#     key    = "terraform.tfstate"
#     region = "ap-southeast-1"
#     encrypt = true
#     dynamodb_table = "remote-state-lock"
#   }
# }

terraform {
  required_version = ">= 0.12.28"
}

provider "aws" {
  version = "~> 2.8"
  region  = var.region
  shared_credentials_file = "<shared_cred_path>"
  profile                 = "tfassesment"
}

locals {
  task2_max_subnet_length = max(
    length(var.private_subnets),
    length(var.database_subnets)
  )
  task2_nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(data.aws_availability_zones.task2_availableaz.names) : local.task2_max_subnet_length
}


data "terraform_remote_state" "commonws" {
  backend = "s3"
  config = {
    bucket = "<state_bucket_name>"
    key    = "env:/commonws/terraform.tfstate"
    shared_credentials_file = "<shared_cred_path>"
    profile                 = "tfassesment"
    region = var.region
  }
}

data "aws_kms_alias" "task2_ssm" {
  name = "alias/aws/ssm"
}

data "aws_kms_alias" "task2_ebs" {
  name = "alias/aws/ebs"
}

data "aws_elb_service_account" "main" {}
# data "aws_kms_alias" "task2_secretmanager" {
#   name = "alias/aws/secretsmanager"
# }

data "aws_region" "task2_current" {}

data "aws_availability_zones" "task2_availableaz" {
    state = "available"
}

data "aws_ami" "task2_amazon-linux-2" {
 most_recent = true
 owners = ["amazon"]

 filter {
   name   = "owner-alias"
   values = ["amazon"]
 }

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
}

data "aws_partition" "task2_current" {}

data "aws_caller_identity" "task2_current" {}


data "archive_file" "task2_init" {
  type        = "zip"
  source_dir = "${path.root}/../application"
  output_path = "${path.root}/../application.zip"
}

# data "archive_file" "task2_appdata" {
#   type        = "zip"
#   source_dir = "${path.root}/../ansible-config"
#   output_path = "${path.root}/../ansible.zip"
# }

module "task2_databucket" {
    source = "../modules/s3"
    bucket_prefix = "databucket"
    s3_bucket_force_destroy = true
    create = var.create
    resource_create = var.task2
    kms_arn = data.terraform_remote_state.commonws.outputs.state_s3_kms_arn
    tags = var.tags
    sse_algorithm = "AES256"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "MYDATABUCKETPOLICY",
  "Statement": [
    {
      "Sid": "ELBAllow",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["${data.aws_elb_service_account.main.arn}"]
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.create && var.task2 && length(module.task2_databucket.bucket_id) > 0 ? element(concat(module.task2_databucket.bucket_id, list("")), 0) : "*"}/logs/AWSLogs/${data.aws_caller_identity.task2_current.account_id}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.create && var.task2 && length(module.task2_databucket.bucket_id) > 0 ? element(concat(module.task2_databucket.bucket_id, list("")), 0) : "*"}/logs/AWSLogs/${data.aws_caller_identity.task2_current.account_id}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${var.create && var.task2 && length(module.task2_databucket.bucket_id) > 0 ? element(concat(module.task2_databucket.bucket_id, list("")), 0) : "*"}"
    }
  ]
}
EOF
}



# module "task2_ansible_upload_archive" {
#   source = "../modules/file_upload_s3"
#   create = var.create
#   resource_create = var.task2
#   bucket_name = join(" ", module.task2_databucket.bucket_id)
#   tags = var.tags
#   file_name = "${path.root}/../ansible.zip"
#   encryption_method = "aws:kms"
#   force_destroy = true
# }

module "task2_application_upload_archive" {
  source = "../modules/file_upload_s3"
  create = var.create
  resource_create = var.task2
  bucket_name = join(" ", module.task2_databucket.bucket_id)
  tags = var.tags
  file_name = "${path.root}/../application.zip"
  encryption_method = "aws:kms"
  force_destroy = true
}

# module "ansible_upload_files" {
#   source = "./modules/file_upload_s3"
#   create = var.create
#   resource_create = var.task1
#   bucket_name = join(" ", module.databucket.bucket_id)
#   tags = var.tags
#   upload_directory = var.upload_directory
#   encryption_method = "aws:kms"
#   force_destroy = true
# }

# resource "null_resource" "upload_to_s3" {
#   count = var.create && var.task1 ? 1 : 0
#   provisioner "local-exec" {
#     command = "aws s3 sync ./ansible-config s3://${element(concat(module.databucket.bucket_id, list("")), 0)} --profile ${var.profile}"

#     # environment = {
#     #   sourcedir = "."
#     #   #bucket = element(concat(module.databucket.bucket_id, list("")), 0)
#     #   bucket = element(concat(module.databucket.bucket_arn, list("")), 0)
#     # }
#   }
# }

module "task2_instance_role_iam_policy" {
  source = "../modules/iam/policy"
  create = var.create
  resource_create = var.task2
  name        = "task2-custom-policy-ec2-s3"
  path        = "/"
  description = "My custom policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "kms:Decrypt",
                "kms:ListKeyPolicies",
                "kms:ListRetirableGrants",
                "kms:Encrypt",
                "kms:GenerateDataKey",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:DescribeKey",
                "kms:Verify",
                "kms:GenerateDataKeyPairWithoutPlaintext",
                "kms:GenerateDataKeyPair",
                "kms:ListGrants"
            ],
            "Resource": [
                "arn:aws:s3:::aws-ssm-region/*",
                "arn:aws:s3:::aws-windows-downloads-region/*",
                "arn:aws:s3:::amazon-ssm-region/*",
                "arn:aws:s3:::amazon-ssm-packages-region/*",
                "arn:aws:s3:::region-birdwatcher-prod/*",
                "arn:aws:s3:::aws-ssm-distributor-file-region/*",
                "arn:aws:s3:::patch-baseline-snapshot-region/*",
                "arn:aws:kms:${data.aws_region.task2_current.name}:${data.aws_caller_identity.task2_current.account_id}:key/*"
            ]
        },
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "kms:ListKeys",
                "iam:PassRole",
                "s3:ListAllMyBuckets",
                "kms:ListAliases"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetEncryptionConfiguration",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::${var.create && var.task2 && length(module.task2_databucket.bucket_id) > 0 ? element(concat(module.task2_databucket.bucket_id, list("")), 0) : "*"}",
                "arn:aws:s3:::${var.create && var.task2 && length(module.task2_databucket.bucket_id) > 0 ? format("%s/%s", element(concat(module.task2_databucket.bucket_id, list("")), 0), "*") : "*"}"
            ]
        }
    ]
}
EOF
}

module "task2_role_policy_attachment" {
    source = "../modules/iam/policy_attachment"
    create = var.create
    resource_create = var.task2
    roles = module.task2_sg_devops_instance_role.role_name
    policy_arn = module.task2_instance_role_iam_policy.arn
}

module "task2_managed_role_policy_attachment" {
  source = "../modules/iam/policy_attachment"
  create = var.create
  resource_create = var.task2
  roles = module.task2_sg_devops_instance_role.role_name
  policy_arn = ["arn:${data.aws_partition.task2_current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

module "task2_managed_secret_role_policy_attachment" {
  source = "../modules/iam/policy_attachment"
  create = var.create
  resource_create = var.task2
  roles = module.task2_sg_devops_instance_role.role_name
  policy_arn = ["arn:${data.aws_partition.task2_current.partition}:iam::aws:policy/SecretsManagerReadWrite"]
}

module "task2_vpc_devops" {
    source = "../modules/network/vpc"
    #count = var.create && var.task1 ? 1 : 0
    create = var.create
    resource_create = var.task2
    cidr = var.cidr
    name = var.name
    # enable_dns_hostnames = var.enable_dns_hostnames
    # enable_dns_support = var.enable_dns_support
    env = var.env
    tags = var.tags
}

module "task2_sub_public_devops" {
    source = "../modules/network/subnets"
    create = var.create
    resource_create = var.task2
    public_subnets  = var.public_subnets
    azs = data.aws_availability_zones.task2_availableaz.names
    # private_subnets = var.private_subnets
    # database_subnets = var.database_subnets
    vpc_id = module.task2_vpc_devops.vpc_id
    one_nat_gateway_per_az = var.one_nat_gateway_per_az
    single_nat_gateway = var.single_nat_gateway
    map_public_ip_on_launch = false
    subnet_suffix = "task2_sub_public_devops"
    tags = var.tags
    env = var.env
}

module "task2_igw" {
    source = "../modules/network/igw"
    public_subnets  = var.public_subnets
    create = var.create
    resource_create = var.task2
    vpc_id = module.task2_vpc_devops.vpc_id
    tags = var.tags
    name = format("%s-%s", var.env, "igw")
}

module "task2_public_rt" {
    source = "../modules/network/rt"
    public_subnets  = var.public_subnets
    create = var.create
    resource_create = var.task2
    vpc_id = module.task2_vpc_devops.vpc_id
    tags = var.tags
    name = format("%s-%s", var.env, "task2_publicrt")
}

module "task2_public_rt_association" {
    source = "../modules/network/rtassoc"
    create = var.create
    resource_create = var.task2
    subnet_id = module.task2_sub_public_devops.public_subnet_id
    rt_id = module.task2_public_rt.public_rt_id
}

module "task2_public_subnet_route" {
    source = "../modules/network/route"
    create = var.create
    resource_create = var.task2
    create_igw = true
    igw_id = module.task2_igw.igw_id
    subnet_id = module.task2_sub_public_devops.public_subnet_id
    rt_id = module.task2_public_rt.public_rt_id    
}

module "task2_nat_gw_eip" {
    source = "../modules/network/eip"
    create = var.create
    resource_create = var.task2
    eip_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(data.aws_availability_zones.task2_availableaz.names) : local.task2_max_subnet_length
    name = "task2_ngw-eip"
    tags = var.tags
}

module "task2_private_subnet_nat_gateway" {
  source = "../modules/network/natgw"
  create = var.create
  resource_create = var.task2
  create_ngw = var.one_nat_gateway_per_az || var.single_nat_gateway ? true : false
  gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(data.aws_availability_zones.task2_availableaz.names) : local.task2_max_subnet_length
  subnet_id = module.task2_sub_public_devops.public_subnet_id
  allocation_id = module.task2_nat_gw_eip.eip_id
  name = "devops-ngw"
  tags = var.tags
}

module "task2_sub_private_devops" {
    source = "../modules/network/subnets"
    create = var.create
    resource_create = var.task2
    private_subnets  = var.private_subnets
    azs = data.aws_availability_zones.task2_availableaz.names
    # private_subnets = var.private_subnets
    # database_subnets = var.database_subnets
    vpc_id = module.task2_vpc_devops.vpc_id
    # one_nat_gateway_per_az = var.one_nat_gateway_per_az
    # single_nat_gateway = var.single_nat_gateway
    subnet_suffix = "task2_sub_private_devops"
    tags = var.tags
    env = var.env
}

module "task2_private_rt" {
    source = "../modules/network/rt"
    private_subnets  = var.private_subnets
    gateway_count = local.task2_nat_gateway_count
    create = var.create
    resource_create = var.task2
    azs = data.aws_availability_zones.task2_availableaz.names
    vpc_id = module.task2_vpc_devops.vpc_id
    tags = var.tags
    name = format("%s-%s", var.env, "task2_privatert")
}

module "task2_private_rt_association" {
    source = "../modules/network/rtassoc"
    create = var.create
    resource_create = var.task2
    subnet_id = module.task2_sub_private_devops.private_subnet_id
    rt_id = module.task2_private_rt.private_rt_id
}

module "task2_private_subnet_route" {
    source = "../modules/network/route"
    create = var.create
    resource_create = var.task2
    create_ngw = var.one_nat_gateway_per_az || var.single_nat_gateway ? true : false
    nat_gw_id = module.task2_private_subnet_nat_gateway.nat_id
    subnet_id = module.task2_sub_private_devops.private_subnet_id
    rt_id = module.task2_private_rt.private_rt_id   
}

module "task2_db_sg" {
    source = "../modules/network/securitygroup"
    create = var.create
    resource_create = var.task2
    vpc_id = module.task2_vpc_devops.vpc_id
    tags = var.tags
    env = var.env
    name = "task2-dbsg-devops"
    description = "DB SG devops group-task2"
    revoke_rules_on_delete = true
}

module "task2_db_sg_ingress" {
    source = "../modules/network/sgrules"
    create = var.create
    resource_create = var.task2
    sg_id = module.task2_db_sg.sg_id
    type = "ingress"
    ingress_rules = var.mysql_ingress_rules
    source_security_group_id = module.task2_sg_devops.sg_id
}

# module "task2_db_sg_ingress_mysql" {
#     source = "../modules/network/sgrules"
#     create = var.create
#     resource_create = var.task2
#     sg_id = module.task2_db_sg.sg_id
#     type = "ingress"
#     ingress_rules = ["mysql-tcp"]
#     cidr_blocks = [var.cidr, "0.0.0.0/0"]
# }

module "task2_db_sg_egress" {
  source = "../modules/network/sgrules"
  create = var.create
  resource_create = var.task2
  sg_id = module.task2_db_sg.sg_id
  ingress_rules = ["all-tcp", "all-udp"]
  cidr_blocks = ["0.0.0.0/0"]
}

module "tas2_db_subnetgrp" {
  source = "../modules/network/db_subnet_grp"
  create = var.create
  resource_create = var.task2
  name = "tas2_db_subnetgrp"
  subnet_ids =  module.task2_sub_private_devops.private_subnet_id
  tags = var.tags  
}

module "task2_rds_mysql" {
  # Configure AWS RDS
  source     	= "../modules/RDS/MYSQL"
  create = var.create
  resource_create = var.task2
  alloc_storage	= "20"
  storage_type 	= "gp2"
  storage_encrypted = true
  engine	= "mysql"
  engine_version= "5.7"
  instance_class= var.db_instance_class
  subnet_group	= module.tas2_db_subnetgrp.db_subnetgrp_name
  public	= "false"
  security_group= module.task2_db_sg.sg_id
  kms_arn = data.aws_kms_alias.task2_ebs.arn
  multi_az = true
  AZ		= data.aws_availability_zones.task2_availableaz.names[0]
  #iam_database_authentication_enabled = false
  identifier	= "CustomerData"
  dbname	= "task2_db"
  dbuser	= var.database_username
  dbpassword	= module.rds_db_secret_manager.db_pass
  databasename = "CustomerData"
  parameter_group= "default.mysql5.7"
  snapshot	= "true"
  tags = var.tags
}


module "task2_instance_role_iam_policy_rds_connect" {
  source = "../modules/iam/policy"
  create = var.create
  resource_create = var.task2
  name        = "custom-policy-ec2-RDS"
  path        = "/"
  description = "My RDS custom policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [ 
                "rds-db:connect"
            ],
            "Resource": [
                "arn:aws:rds-db:${var.region}:${data.aws_caller_identity.task2_current.account_id}:dbuser:${var.create && var.task2 && length(module.task2_rds_mysql.rds_resource_id) > 0 ? element(concat(module.task2_rds_mysql.rds_resource_id, list("")), 0) : "*"}/${var.database_username}"
            ]
        }
    ]
}
EOF
}

module "task2_rds_role_policy_attachment" {
    source = "../modules/iam/policy_attachment"
    create = var.create
    resource_create = var.task2
    roles = module.task2_sg_devops_instance_role.role_name
    policy_arn = module.task2_instance_role_iam_policy_rds_connect.arn
}

module "task2_sg_devops" {
    source = "../modules/network/securitygroup"
    create = var.create
    resource_create = var.task2
    vpc_id = module.task2_vpc_devops.vpc_id
    tags = var.tags
    env = var.env
    name = "task2_sg-devops"
    description = "SG devops group-task2"
    revoke_rules_on_delete = true
}

module "task2_sg_devops_ingress" {
    source = "../modules/network/sgrules"
    create = var.create
    resource_create = var.task2
    sg_id = module.task2_sg_devops.sg_id
    type = "ingress"
    ingress_rules = var.public_ingress_rules
    cidr_blocks = [var.cidr, "0.0.0.0/0"]
}

module "task2_sg_devops_egress" {
  source = "../modules/network/sgrules"
  create = var.create
  resource_create = var.task2
  sg_id = module.task2_sg_devops.sg_id
  ingress_rules = ["all-tcp", "all-udp"]
  cidr_blocks = ["0.0.0.0/0"]
}

module "task2_sg_devops_keygen" {
    source = "../modules/keygen"
    create = var.create
    resource_create = var.task2
}

module "task2_sg_devops_keypair" {
    source = "../modules/keypair"
    create = var.create
    resource_create = var.task2
    key_name = format("%s-%s", var.env, "task2_keypair")
    public_key = module.task2_sg_devops_keygen.key_public_openssh
}

module "task2_sg_devops_ssm" {
    source = "../modules/ssm"
    create = var.create
    resource_create = var.task2
    name = format("/%s-%s/%s/%s", "task2_vpc", var.env, "keypair", "private")
    type = "SecureString"
    value = module.task2_sg_devops_keygen.key_private_pem
    key_id = data.aws_kms_alias.task2_ssm.arn
    description = "task2_private key"
    overwrite = true
    tags = var.tags
}

module "rds_db_secret_manager" {
  source = "../modules/secret-manager"
  create = var.create
  resource_create = var.task2
#   kms_key_id = data.aws_kms_alias.task2_ssm.arn
  name = "task2_db_secret"
  tags = var.tags
}

module "task2_sg_devops_instance_role" {
    source = "../modules/iam/instance_role"
    create = var.create
    resource_create = var.task2
    name = "task2_ec2-role"
    tags = var.tags
}

module "task2_sg_devops_instance_profile" {
    source = "../modules/iam/instance_profile"
    create = var.create
    resource_create = var.task2
    name = "task2_ec2_devops-role"
    role = module.task2_sg_devops_instance_role.role_name
}

data "template_file" "init" {
  count = var.create &&  var.task2 ? 1 : 0
  template = "${file("${path.root}/../scripts/init.sh.tpl")}"
  vars = {
    dbuser	= var.database_username
    dbpassword	= module.rds_db_secret_manager.db_pass
    secret_name = element(concat(module.rds_db_secret_manager.secret_name, list("")), count.index)
    bucket_name = format("%s/%s", element(concat(module.task2_databucket.bucket_id, list("")), 0), "application.zip")
    dbendpoint = element(concat(module.task2_rds_mysql.rds_endpoint, list("")), count.index)
  }
}


module "task2_asg_launchconfig" {
  # Configure AWS LaunchConfig
  source     	= "../modules/AutoScaling/LaunchConfiguration"
  create = var.create
  resource_create = var.task2
  ami		= data.aws_ami.task2_amazon-linux-2.id
  name = "task2_asg"
  instance_type		= var.instance_type
  iam_instance_profile   = join("", module.task2_sg_devops_instance_profile.instance_profile_name)
  #securitygroup = module.task2_sg_devops.sg_id
  key_name               = module.task2_sg_devops_keypair.keypair_name
  #user_data = length(data.template_file.init[0].rendered) > 0 ? data.template_file.init[0].rendered : null
  user_data = try(data.template_file.init[0].rendered, null)
  vpc_security_group_ids = module.task2_sg_devops.sg_id

  root_block_device = [
        {
        volume_type = "gp2"
        volume_size = 10
        },
    ]

    ebs_block_device = [
        {
        device_name = "/dev/sdf"
        volume_type = "gp2"
        volume_size = 5
        encrypted   = true
        kms_key_id  = data.aws_kms_alias.task2_ebs.arn
        }
    ]
}

module "task2_elb" {
  # Configure AWS Loadbalancing
  source     	= "../modules/AutoScaling/ELB"
  create = var.create
  resource_create = var.task2
  name = "tas2-elb-front"
  subnets         = module.task2_sub_public_devops.public_subnet_id
  security_groups = module.task2_sg_devops.sg_id
  internal        = false

  listener = [
    {
      instance_port     = "5000"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = {
    target              = "HTTP:5000/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  access_logs = {
    bucket = element(concat(module.task2_databucket.bucket_id, list("")), 0)
    bucket_prefix = "logs"
  }
  
  tags = var.tags
}

module "asg" {
  source = "../modules/AutoScaling/ASG"
  create = var.create
  resource_create = var.task2
  name = "task2-devops-asg"
  launch_configuration = module.task2_asg_launchconfig.launchconfigurationname
  vpc_zone_identifier = module.task2_sub_public_devops.public_subnet_id
  max_size = 3
  min_size = 2
  desired_capacity = 2
  load_balancers = module.task2_elb.elb_name
  tags_as_map = var.asg_tags
  health_check_type = "EC2"  
}

# module "AutoScalingGroup" {
#   # Configure AWS ASG
#   source = "./Modules/AutoScaling/ASG/"
#   launchconfiguration	= "${module.AutoScaling-LaunchConfiguration.launchconfiguration}"
#   subnet_list		= ["${module.network-subnet.subnet_pub1}", "${module.network-subnet.subnet_pub2}"]
#   min_instance		= 2
#   max_instance		= 4
#   loadbalancer		= ["${module.AutoScaling-ELB.ELBName}"]
#   healthchecktype	= "ELB"
#   name			= "PyASG"
# }



# module "task2_ec2_devops"{
#     source = "../modules/ec2"
#     name                   = "ec2_devops"
#     instance_count         = var.instance_count
#     create = var.create
#     resource_create = var.task2
#     ami                    = data.aws_ami.task2_amazon-linux-2.id
#     instance_type          = var.instance_type
#     key_name               = module.task2_sg_devops_keypair.keypair_name
#     #user_data = length(data.template_file.init[0].rendered) > 0 ? data.template_file.init[0].rendered : null
#     user_data = try(data.template_file.init[0].rendered, null)
#     iam_instance_profile   = join("", module.task2_sg_devops_instance_profile.instance_profile_name)
#     monitoring             = true
#     vpc_security_group_ids = module.task2_sg_devops.sg_id
#     bucket_name = format("%s/%s", element(concat(module.task2_databucket.bucket_id, list("")), 0), "ansible.zip")
#     subnet_ids           = module.task2_sub_public_devops.public_subnet_id
#     root_block_device = [
#         {
#         volume_type = "gp2"
#         volume_size = 10
#         },
#     ]

#     ebs_block_device = [
#         {
#         device_name = "/dev/sdf"
#         volume_type = "gp2"
#         volume_size = 5
#         encrypted   = true
#         kms_key_id  = data.aws_kms_alias.task2_ebs.arn
#         }
#     ]
#     tags = var.tags
# }

# module "task2_ec2_devops_eip" {
#      source = "../modules/network/eip"
#      create = var.create
#      resource_create = var.task2
#      eip_count = var.instance_count
#      name = "task2_ec2_devops-eip"
#      tags = var.tags
# }

# module "task2_ec2_devops_ec2_eip_association" {
#      source = "../modules/network/eipassocation"
#      create = var.create
#      resource_create = var.task2
#      assoc_count = var.instance_count
#      instance_association = true
#      allocation_id = module.task2_ec2_devops_eip.eip_id
#      instance_id = module.task2_ec2_devops.ec2_id
# }

##############################################

#---------------------------------------------------------------------------------------------------
# Output Block
#---------------------------------------------------------------------------------------------------

output "task2_account_id" {
  value = "${data.aws_caller_identity.task2_current.account_id}"
}

output "task2_caller_arn" {
  value = "${data.aws_caller_identity.task2_current.arn}"
}

output "task2_caller_user" {
  value = "${data.aws_caller_identity.task2_current.user_id}"
}

output "task2_availabeaznames" {
    value = data.aws_availability_zones.task2_availableaz.names
}

output "task2_availabeazid" {
    value = data.aws_availability_zones.task2_availableaz.zone_ids
}

output "task2_regionname" {
    value = data.aws_region.task2_current.name
}

output "task2_vpc_id" {
    value = module.task2_vpc_devops.vpc_id
}

output "task2_vpc_arn" {
    value = module.task2_vpc_devops.vpc_arn
}

output "task2_vpc_cidr_block" {
    value = module.task2_vpc_devops.vpc_cidr_block
}

output "task2_public_subnet_id" {
    value = module.task2_sub_public_devops.public_subnet_id
}

output "task2_public_subnet_arn" {
    value = module.task2_sub_public_devops.public_subnet_arn
}

output "task2_private_subnet_id" {
    value = module.task2_sub_private_devops.private_subnet_id
}

output "task2_private_subnet_arn" {
    value = module.task2_sub_private_devops.private_subnet_arn
}

output "task2_sg_devops_sgname" {
    value = module.task2_sg_devops.sg_name
}

output "task2_sg_devops_sgarn" {
    value = module.task2_sg_devops.sg_arn
}

output "task2_sg_devops_sgid" {
    value = module.task2_sg_devops.sg_id
}

output "task2_sg_devops_publicrule_ingress_id" {
    value = module.task2_sg_devops_ingress.sg_rule_id
}

output "task2_sg_devops_keypair_ssmarn" {
    value = module.task2_sg_devops_ssm.ssm_arn
}

# output "task2_ec2_instance_id" {
#     value = module.task2_ec2_devops.ec2_id
# }

# output "task2_ec2_instance_arn" {
#     value = module.task2_ec2_devops.ec2_arn
# }

# output "task2_ec2_instance_publicdns" {
#     value = module.task2_ec2_devops.ec2_public_dns
# }

# output "task2_ec2_instance_privatedns" {
#     value = module.task2_ec2_devops.ec2_private_dns
# }

# output "task2_ec2_instance_privateip" {
#     value = module.task2_ec2_devops.ec2_private_ip
# }

# output "task2_ec2_instance_sgid" {
#     value = module.task2_ec2_devops.vpc_security_group_ids
# }

# output "task2_ec2_instance_rootvolume" {
#     value = module.task2_ec2_devops.root_block_device_volume_ids
# }

# output "task2_ec2_instance_ebsvolume" {
#     value = module.task2_ec2_devops.ebs_block_device_volume_ids
# }

# output "task2_ec2_instance_publicip" {
#     value = module.task2_ec2_devops_eip.eip_publicip
# }

output "task2_igw_id" {
    value = module.task2_igw.igw_id
}

output "task2_igw_arn" {
    value = module.task2_igw.igw_arn
}

output "task2_databucket_id" {
    value = module.task2_databucket.bucket_id
}

output "task2_databucket_arn" {
    value = module.task2_databucket.bucket_arn
}

output "task2_databucket_domainname" {
    value = module.task2_databucket.bucket_domain_name
}

output "task2_custom_policy_id" {
  description = "The policy's ID"
  value       = module.task2_instance_role_iam_policy.id
}

output "task2_custom_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = module.task2_instance_role_iam_policy.arn
}

output "task2_custom_policy_name" {
  description = "The name of the policy"
  value       = module.task2_instance_role_iam_policy.name
}

output "task2_custom_policy_policydoc" {
  description = "The policy document"
  value       = module.task2_instance_role_iam_policy.policy
}

output "task2_public_subnet_route_id" {
    value = module.task2_public_subnet_route.public_route_id
}

output "task2_publicsubnet_rt_association_id" {
    value = module.task2_public_rt_association.subnet_rt_association_id
}

output "task2_public_rt_id" {
    value = module.task2_public_rt.public_rt_id
}

output "task2_private_rt_id" {
    value = module.task2_public_rt.private_rt_id
}

output "elb_arn" {
    value = module.task2_elb.elb_arn
}

output "elb_id" {
    value = module.task2_elb.elb_id
}

output "elb_name" {
    value = module.task2_elb.elb_name
}

output "customers_page" {
    description = "Hit enpoint for getting data"
    value = formatlist("%s%s%s", "http://", module.task2_elb.elb_dns_name, "/customers")
}

output "add_customer" {
    description = "Hit enpoint for getting data"
    value = formatlist("%s%s", "http://", module.task2_elb.elb_dns_name, "/add")
}

output "elb_zone_id" {
    value = module.task2_elb.elb_zone_id
}

output "mysqlenpoint" {
    value = module.task2_rds_mysql.rds_endpoint
}

output "mysqladdress" {
    value = module.task2_rds_mysql.rds_address
}

output "mysqlid" {
    value = module.task2_rds_mysql.rds_id
}

output "mysqlarn" {
    value = module.task2_rds_mysql.rds_arn
}

output "mysqlresourceid" {
    value = module.task2_rds_mysql.rds_resource_id
}

output "commonws" {
    value = data.terraform_remote_state.commonws.outputs.state_bucket_id
}
