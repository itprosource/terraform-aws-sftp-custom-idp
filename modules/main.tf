provider "aws" {
  region = "us-east-1"
}

# As stated in README, my current IDP user password mgmt technique is to use sensitive Terraform variables hosted in
# Hashicorp Cloud. To do this, you must declare an empty variable for each user password. I recommend naming each
# variable with simply "_pw" appended to the username.
variable "bsmith_pw" {
  sensitive = true
}
variable "svc-acct-app_pw" {
  sensitive = true
}

module "sftp" {
  source = "../"

  # Create a name that will be used to either tag most resources or prefix to their resource name
  # for identification purposes.
  name        = "sftp-example"

  # Set your VPC network details.
  cidr        = "10.0.1.0/24"
  subnet_cidr = "10.0.1.0/24"
  az          = "us-east-1a"

  # Name your s3 bucket into which SFTP will deposit files.
  bucket_name = "example-bucket-042722"

  # IDP user mgmt is below. Each key is the username, while the provided values point to their password and
  # optional HomeDirectory (leave quotes empty for the account to default to the root s3 directory).
  # NOTE ON PASSWORDS: As described in the README, it's not secure to encode the actual password string here.
  # In my current use-case, those values are hosted in a Hashicorp Cloud workspace as sensitive Terraform variables.
  # As long as you have entered the empty variables above AND created the same variable with the actual password value
  # in your Cloud workspace, then this template will grab the secret during execution without being exposed.
  # Afterwards, the password can be securely viewed in Secrets Manager as normal.
  # NOTE ON HOMEDIRECTORY: If you specify a HomeDirectory folder, then a folder will automatically be created
  # in the s3 bucket.
  # Refer back to the README for more discussion.
  idp_users = {
    bsmith02 = {
      Password = var.bsmith_pw
      HomeDirectory = "bsmith-home"
    },
    svc_acct-app02 = {
      Password = var.svc-acct-app_pw
      HomeDirectory = "accounting"
    }
  }

  # Create your security group ingress rules. The security group is hardcoded to allow only port 22,
  # all you need to provide are the IP rules. The below example shows a single rule which allows connections
  # from anywhere, but you could instead restrict based on IP and create multiple rules - simply add
  # "rule02", "rule03", and so on.
  ingress_rules = {
    rule01 = {
      cidr    = "0.0.0.0/0"
      desc    = "Allow All"
    }
  }

  # Security policy under which the transfer server operates. Generally should not need to change until
  # next policy update, but you might decide to use other security policies for various reasons.
  security_policy_name = "TransferSecurityPolicy-2020-06"

  # Name for the REST API and Lambda function. I recommend leaving at the below but you can name
  # them in whatever manner makes sense for you.
  rest_api_name = "custom_idp_transfer_server"
  function_name = "custom_idp_for_sftp"

}