# Backend config
terraform {
  backend "s3" {
    shared_credentials_file = "<shared_cred_path>"
    profile                 = "tfassesment"
    bucket = "<state_bucket_name>"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
    encrypt = true
    dynamodb_table = "remote-state-lock"
  }
}

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
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.database_subnets)
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(data.aws_availability_zones.availableaz.names) : local.max_subnet_length
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


data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}

data "aws_region" "current" {}

data "aws_availability_zones" "availableaz" {
    state = "available"
}

data "aws_ami" "amazon-linux-2" {
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

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "archive_file" "init" {
  type        = "zip"
  source_dir = "${path.root}/../ansible-config"
  output_path = "${path.root}/../ansible.zip"
}

module "databucket" {
    source = "../modules/s3"
    bucket_prefix = "ansiblebucket"
    s3_bucket_force_destroy = true
    create = var.create
    resource_create = var.task1
    kms_arn = data.terraform_remote_state.commonws.outputs.state_s3_kms_arn
    tags = var.tags
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "RequireEncryption",
   "Statement": [
    {
      "Sid": "RequireEncryptedTransport",
      "Effect": "Deny",
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::${var.create && var.task1 && length(module.databucket.bucket_id) > 0 ? element(concat(module.databucket.bucket_id, list("")), 0) : "*"}/*"],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    },
    {
      "Sid": "RequireEncryptedStorage",
      "Effect": "Deny",
      "Action": ["s3:PutObject"],
      "Resource": ["arn:aws:s3:::${var.create && var.task1 && length(module.databucket.bucket_id) > 0 ? element(concat(module.databucket.bucket_id, list("")), 0) : "*"}/*"],
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      },
      "Principal": "*"
    }
  ]
}
EOF
}

module "ansible_upload_archive" {
  source = "../modules/file_upload_s3"
  create = var.create
  resource_create = var.task1
  bucket_name = join(" ", module.databucket.bucket_id)
  tags = var.tags
  file_name = "${path.root}/../ansible.zip"
  encryption_method = "AES256"
  force_destroy = true
}

# module "ansible_upload_files" {
#   source = "../modules/file_upload_s3"
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

module "instance_role_iam_policy" {
  source = "../modules/iam/policy"
  create = var.create
  resource_create = var.task1
  name        = "custom-policy-ec2-s3"
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
                "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/*"
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
                "arn:aws:s3:::${var.create && var.task1 && length(module.databucket.bucket_id) > 0 ? element(concat(module.databucket.bucket_id, list("")), 0) : "*"}",
                "arn:aws:s3:::${var.create && var.task1 && length(module.databucket.bucket_id) > 0 ? format("%s/%s", element(concat(module.databucket.bucket_id, list("")), 0), "*") : "*"}"
            ]
        }
    ]
}
EOF
}

module "role_policy_attachment" {
    source = "../modules/iam/policy_attachment"
    create = var.create
    resource_create = var.task1
    roles = module.sg_devops_instance_role.role_name
    policy_arn = module.instance_role_iam_policy.arn
}

module "managed_role_policy_attachment" {
  source = "../modules/iam/policy_attachment"
  create = var.create
  resource_create = var.task1
  roles = module.sg_devops_instance_role.role_name
  policy_arn = ["arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

module "vpc_devops" {
    source = "../modules/network/vpc"
    #count = var.create && var.task1 ? 1 : 0
    create = var.create
    resource_create = var.task1
    cidr = var.cidr
    name = var.name
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support
    env = var.env
    tags = var.tags
}

module "sub_public_devops" {
    source = "../modules/network/subnets"
    create = var.create
    resource_create = var.task1
    public_subnets  = var.public_subnets
    azs = data.aws_availability_zones.availableaz.names
    # private_subnets = var.private_subnets
    # database_subnets = var.database_subnets
    vpc_id = module.vpc_devops.vpc_id
    one_nat_gateway_per_az = var.one_nat_gateway_per_az
    single_nat_gateway = var.single_nat_gateway
    map_public_ip_on_launch = false
    subnet_suffix = "sub_public_devops"
    tags = var.tags
    env = var.env
}

module "igw" {
    source = "../modules/network/igw"
    public_subnets  = var.public_subnets
    create = var.create
    resource_create = var.task1
    vpc_id = module.vpc_devops.vpc_id
    tags = var.tags
    name = format("%s-%s", var.env, "igw")
}

module "public_rt" {
    source = "../modules/network/rt"
    public_subnets  = var.public_subnets
    create = var.create
    resource_create = var.task1
    vpc_id = module.vpc_devops.vpc_id
    tags = var.tags
    name = format("%s-%s", var.env, "publicrt")
}

module "public_rt_association" {
    source = "../modules/network/rtassoc"
    create = var.create
    resource_create = var.task1
    subnet_id = module.sub_public_devops.public_subnet_id
    rt_id = module.public_rt.public_rt_id
}

module "public_subnet_route" {
    source = "../modules/network/route"
    create = var.create
    resource_create = var.task1
    create_igw = true
    igw_id = module.igw.igw_id
    subnet_id = module.sub_public_devops.public_subnet_id
    rt_id = module.public_rt.public_rt_id    
}

module "nat_gw_eip" {
    source = "../modules/network/eip"
    create = var.create
    resource_create = var.task1
    eip_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(data.aws_availability_zones.availableaz.names) : local.max_subnet_length
    name = "ngw-eip"
    tags = var.tags
}

module "private_subnet_nat_gateway" {
  source = "../modules/network/natgw"
  create = var.create
  resource_create = var.task1
  create_ngw = var.one_nat_gateway_per_az || var.single_nat_gateway ? true : false
  gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(data.aws_availability_zones.availableaz.names) : local.max_subnet_length
  subnet_id = module.sub_public_devops.public_subnet_id
  allocation_id = module.nat_gw_eip.eip_id
  name = "devops-ngw"
  tags = var.tags
}

module "sub_private_devops" {
    source = "../modules/network/subnets"
    create = var.create
    resource_create = var.task1
    private_subnets  = var.private_subnets
    azs = data.aws_availability_zones.availableaz.names
    # private_subnets = var.private_subnets
    # database_subnets = var.database_subnets
    vpc_id = module.vpc_devops.vpc_id
    # one_nat_gateway_per_az = var.one_nat_gateway_per_az
    # single_nat_gateway = var.single_nat_gateway
    subnet_suffix = "sub_private_devops"
    tags = var.tags
    env = var.env
}

module "private_rt" {
    source = "../modules/network/rt"
    private_subnets  = var.private_subnets
    gateway_count = local.nat_gateway_count
    create = var.create
    resource_create = var.task1
    azs = data.aws_availability_zones.availableaz.names
    vpc_id = module.vpc_devops.vpc_id
    tags = var.tags
    name = format("%s-%s", var.env, "privatert")
}

module "private_rt_association" {
    source = "../modules/network/rtassoc"
    create = var.create
    resource_create = var.task1
    subnet_id = module.sub_private_devops.private_subnet_id
    rt_id = module.private_rt.private_rt_id
}

module "private_subnet_route" {
    source = "../modules/network/route"
    create = var.create
    resource_create = var.task1
    create_ngw = var.one_nat_gateway_per_az || var.single_nat_gateway ? true : false
    nat_gw_id = module.private_subnet_nat_gateway.nat_id
    subnet_id = module.sub_private_devops.private_subnet_id
    rt_id = module.private_rt.private_rt_id   
}

module "sg_devops" {
    source = "../modules/network/securitygroup"
    create = var.create
    resource_create = var.task1
    vpc_id = module.vpc_devops.vpc_id
    tags = var.tags
    env = var.env
    name = "sg-devops"
    description = "SG devops group"
    revoke_rules_on_delete = true
}

module "sg_devops_ingress" {
    source = "../modules/network/sgrules"
    create = var.create
    resource_create = var.task1
    sg_id = module.sg_devops.sg_id
    type = "ingress"
    ingress_rules = var.public_ingress_rules
    cidr_blocks = [var.cidr, "0.0.0.0/0"]
}

module "sg_devops_egress" {
  source = "../modules/network/sgrules"
  create = var.create
  resource_create = var.task1
  sg_id = module.sg_devops.sg_id
  ingress_rules = ["all-tcp", "all-udp"]
  cidr_blocks = ["0.0.0.0/0"]
}

module "sg_devops_keygen" {
    source = "../modules/keygen"
    create = var.create
    resource_create = var.task1
}

module "sg_devops_keypair" {
    source = "../modules/keypair"
    create = var.create
    resource_create = var.task1
    key_name = format("%s-%s", var.env, "keypair")
    public_key = module.sg_devops_keygen.key_public_openssh
}

module "sg_devops_ssm" {
    source = "../modules/ssm"
    create = var.create
    resource_create = var.task1
    name = format("/%s-%s/%s/%s", "vpc", var.env, "keypair", "private")
    type = "SecureString"
    value = module.sg_devops_keygen.key_private_pem
    key_id = data.aws_kms_alias.ssm.arn
    description = "private key"
    overwrite = true
    tags = var.tags
}

module "sg_devops_instance_role" {
    source = "../modules/iam/instance_role"
    create = var.create
    resource_create = var.task1
    name = "ec2-role"
    tags = var.tags
}

module "sg_devops_instance_profile" {
    source = "../modules/iam/instance_profile"
    create = var.create
    resource_create = var.task1
    name = "ec2_devops-role"
    role = module.sg_devops_instance_role.role_name
}

data "template_file" "task1init" {
  count = var.create &&  var.task1 ? 1 : 0
  template = "${file("${path.root}/../scripts/task1.sh.tpl")}"
  vars = {
    bucket_name = format("%s/%s", element(concat(module.databucket.bucket_id, list("")), 0), "ansible.zip")
  }
}

module "ec2_devops"{
    source = "../modules/ec2"
    name                   = "ec2_devops"
    instance_count         = var.instance_count
    create = var.create
    resource_create = var.task1
    user_data = try(data.template_file.task1init[0].rendered, null)
    ami                    = data.aws_ami.amazon-linux-2.id
    instance_type          = var.instance_type
    key_name               = module.sg_devops_keypair.keypair_name
    iam_instance_profile   = join("", module.sg_devops_instance_profile.instance_profile_name)
    monitoring             = true
    vpc_security_group_ids = module.sg_devops.sg_id
    bucket_name = format("%s/%s", element(concat(module.databucket.bucket_id, list("")), 0), "ansible.zip")
    subnet_ids           = module.sub_public_devops.public_subnet_id
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
        kms_key_id  = data.aws_kms_alias.ebs.arn
        }
    ]
    tags = var.tags
}

module "ec2_devops_eip" {
    source = "../modules/network/eip"
    create = var.create
    resource_create = var.task1
    eip_count = var.instance_count
    name = "ec2_devops-eip"
    tags = var.tags
}

module "ec2_devops_ec2_eip_association" {
    source = "../modules/network/eipassocation"
    create = var.create
    resource_create = var.task1
    assoc_count = var.instance_count
    instance_association = true
    allocation_id = module.ec2_devops_eip.eip_id
    instance_id = module.ec2_devops.ec2_id
}

# ##############################################

# #---------------------------------------------------------------------------------------------------
# # Output Block
# #---------------------------------------------------------------------------------------------------

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "caller_arn" {
  value = "${data.aws_caller_identity.current.arn}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.current.user_id}"
}

output "availabeaznames" {
    value = data.aws_availability_zones.availableaz.names
}

output "availabeazid" {
    value = data.aws_availability_zones.availableaz.zone_ids
}

output "regionname" {
    value = data.aws_region.current.name
}

output "vpc_id" {
    value = module.vpc_devops.vpc_id
}

output "vpc_arn" {
    value = module.vpc_devops.vpc_arn
}

output "vpc_cidr_block" {
    value = module.vpc_devops.vpc_cidr_block
}

output "public_subnet_id" {
    value = module.sub_public_devops.public_subnet_id
}

output "public_subnet_arn" {
    value = module.sub_public_devops.public_subnet_arn
}

output "private_subnet_id" {
    value = module.sub_private_devops.private_subnet_id
}

output "private_subnet_arn" {
    value = module.sub_private_devops.private_subnet_arn
}

output "sg_devops_sgname" {
    value = module.sg_devops.sg_name
}

output "sg_devops_sgarn" {
    value = module.sg_devops.sg_arn
}

output "sg_devops_sgid" {
    value = module.sg_devops.sg_id
}

output "sg_devops_publicrule_ingress_id" {
    value = module.sg_devops_ingress.sg_rule_id
}

output "sg_devops_keypair_ssmarn" {
    value = module.sg_devops_ssm.ssm_arn
}

output "ec2_instance_id" {
    value = module.ec2_devops.ec2_id
}

output "ec2_instance_arn" {
    value = module.ec2_devops.ec2_arn
}

output "ec2_instance_publicdns" {
    value = module.ec2_devops.ec2_public_dns
}

output "ec2_instance_privatedns" {
    value = module.ec2_devops.ec2_private_dns
}

output "ec2_instance_privateip" {
    value = module.ec2_devops.ec2_private_ip
}

output "ec2_instance_sgid" {
    value = module.ec2_devops.vpc_security_group_ids
}

output "ec2_instance_rootvolume" {
    value = module.ec2_devops.root_block_device_volume_ids
}

output "ec2_instance_ebsvolume" {
    value = module.ec2_devops.ebs_block_device_volume_ids
}

output "apache_home_page" {
    value = formatlist("%s%s", "http://", module.ec2_devops_eip.eip_publicip)
}

output "tomcat_home_page" {
    value = formatlist("%s%s:%s", "http://", module.ec2_devops_eip.eip_publicip, "8080")
}

output "igw_id" {
    value = module.igw.igw_id
}

output "igw_arn" {
    value = module.igw.igw_arn
}

output "databucket_id" {
    value = module.databucket.bucket_id
}

output "databucket_arn" {
    value = module.databucket.bucket_arn
}

output "databucket_domainname" {
    value = module.databucket.bucket_domain_name
}

output "custom_policy_id" {
  description = "The policy's ID"
  value       = module.instance_role_iam_policy.id
}

output "custom_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = module.instance_role_iam_policy.arn
}

output "custom_policy_name" {
  description = "The name of the policy"
  value       = module.instance_role_iam_policy.name
}

output "custom_policy_policydoc" {
  description = "The policy document"
  value       = module.instance_role_iam_policy.policy
}

output "public_subnet_route_id" {
    value = module.public_subnet_route.public_route_id
}

output "publicsubnet_rt_association_id" {
    value = module.public_rt_association.subnet_rt_association_id
}


output "public_rt_id" {
    value = module.public_rt.public_rt_id
}

output "private_rt_id" {
    value = module.public_rt.private_rt_id
}

# output "ansible_upload_objects_id" {
#   value = module.ansible_upload_files.object_id
# }

# output "ansible_upload_objects_version_id" {
#   value = module.ansible_upload_files.object_version_id
# }

# ################ un-used block ##########################
# # # output "ec2_eip_association_id" {
# # #     value = modue.ec2_devops_ec2_eip_association.eip_association_id
# # # }
# # # module "terraformuser" {
# # #     source = "./iam/user/user.tf"
# # #     name = "terraformuser"
# # #     count = var.create ? 1 : 0
# # # }

# # # module "terraforms3" {
# # #     source = "./s3/s3.tf"
# # #     bucket_prefix = var.state_bucket_prefix
# # #     s3_bucket_force_destroy = var.s3_bucket_force_destroy
# # #     kms_arn = var.kms_arn
# # #     count = var.create ? 1 : 0
# # # }

# # # resource "aws_iam_user_policy_attachment" "remote_state_access" {
# # #   user       = module.terraformuser.user_name
# # #   policy_arn = module.remote_state.terraform_iam_policy.arn
# # # }
# # output "role_attachment_id" {
# #     value = module.role_policy_attachment.role_attachment_id
# # }

# # output "role_attachment_name" {
# #     value = module.role_policy_attachment.role_attachment_name
# # }

# module "ssmdoc" {
#     source = "../modules/ssm_document"
#     name = "AWS-ApplyAnsiblePlaybooks"
# }

# module "ssmdocassociation" {
#     source = "../modules/ssm_associaton"
#     create = var.create
#     resource_create = var.task1
#     instance_id = module.ec2_devops.ec2_id
#     doc_name = "AWS-ApplyAnsiblePlaybooks"
#     s3_bucket_name = module.databucket.bucket_id
#     parameters = {
#     sourceType = "S3"
#     sourceInfo = <<EOJ
#       {
#           "path": "${format("%s/%s", element(concat(module.databucket.bucket_domain_name, list("")), 0), "sample.yaml")}"
#       }
#       EOJ
#   }
# }

