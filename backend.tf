terraform {
  required_version = ">= 0.12.28"
}

provider "aws" {
  version = "~> 2.8"
  region  = var.region
  shared_credentials_file = "<shared_cred_path>"
  profile                 = "tfassesment"
}

data "aws_kms_alias" "s3" {
  name = "alias/aws/s3"
}


resource "aws_s3_bucket" "s3" {
  count         = var.create ? 1 : 0
  bucket_prefix = var.state_bucket_prefix
  acl           = "private"
  force_destroy = var.state_bucket_force_destroy

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = data.aws_kms_alias.s3.arn
      }
    }
  }
  tags = var.tags
}


resource "aws_s3_bucket_policy" "terraform_state" {
  count = var.create ? 1 : 0
  bucket = aws_s3_bucket.s3[count.index].id
  policy =<<EOF
{
  "Version": "2012-10-17",
  "Id": "RequireEncryption",
   "Statement": [
    {
      "Sid": "RequireEncryptedTransport",
      "Effect": "Deny",
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3[count.index].id}/*"],
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
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.s3[count.index].id}/*"],
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


#---------------------------------------------------------------------------------------------------
# DynamoDB Table for State Locking
#---------------------------------------------------------------------------------------------------
locals {
  # The table must have a primary key named LockID.
  lock_key_id = "LockID"
}

resource "aws_dynamodb_table" "lock" {
  count = var.create ? 1 : 0
  name         = var.dynamodb_table_name
  billing_mode = var.dynamodb_table_billing_mode
  hash_key     = local.lock_key_id
  server_side_encryption {
    enabled = true
  }
  attribute {
    name = local.lock_key_id
    type = "S"
  }

  tags = var.tags
}

#terraform {
 # backend "s3" {
  #  shared_credentials_file = "<shared_cred_path>"
   # profile                 = "tfassesment"
   # bucket = "<state_bucket_name>"
   # key    = "terraform.tfstate"
   # region = "ap-southeast-1"
   # encrypt = true
   # dynamodb_table = "remote-state-lock"
  #}
#}


output "state_bucket_id" {
  value = aws_s3_bucket.s3[*].id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.lock[*].id
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.lock[*].arn
}

output "state_s3_kms_arn" {
  value = data.aws_kms_alias.s3.arn
}
