provider "aws" {
  region = "us-east-1"
}

module "sftp" {
  source = "../"

  name = "sftp-example"
  bucket_name = "testingbucketaustin"

  cidr = "10.0.1.0/24"
  subnet_cidr = "10.0.1.0/24"
  az = "us-east-1a"

  ingress_rules = {
    rule01 = {
      cidr = "0.0.0.0/0"
      desc = "Allow All"
    }
  }

  security_policy_name = "TransferSecurityPolicy-2020-06"

  rest_api_name = "custom_idp_transfer_server"

  idp_users = {
    secret01 = {
      Password      = "Welcome123!",
      HomeDirectory = "/testingbucketaustin/test-directory",
      Role          = "arn:aws:iam::328270397459:role/custom_idp_sftp_role",
    },
    secret02 = {
      Password      = "Welcome321!",
      HomeDirectory = "/testingbucketaustin/test-directory",
      Role          = "arn:aws:iam::328270397459:role/custom_idp_sftp_role",
    }
  }

  secrets = {
    secret01 = "SFTP/test19"
    secret02 = "SFTP/test20"
  }


}