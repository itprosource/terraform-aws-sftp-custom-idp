provider "aws" {
  region = "us-east-1"
}

module "sftp" {
  source = "../"

  # Create a name that will be used to either tag most resources or prefix to their resource name
  # for identification purposes.
  name = "sftp-example"

  # Set your VPC network details.
  cidr = "10.0.1.0/24"
  subnet_cidr = "10.0.1.0/24"
  az = "us-east-1a"

  # Name your s3 bucket into which SFTP will deposit files.
  bucket_name = ""

  # Name your SFTP user accounts.
  # To add an additional user, enter the next user number (user03, etc) and set it equal to the username.
  # The user number will not appear in AWS, it's ony used by Terraform to order the secrets.
  # Only the username will be used to name the secret.
  secrets = {
    user01 = "test29",
    user02 = "test30"
  }

  # Optionally, you can create additional s3 folders for use as Home Directories. Not required.
  folders = {
    folder01 = "test-01",
    folder02 = "test-02"
  }

  # Create your security group ingress rules. The security group is configured to allow only port 22,
  # all you need to provide are the IP rules. The below example shows a single rule which allows connections
  # from anywhere, but you could instead restrict based on IP and create multiple rules - simply add
  # "rule02", "rule03", and so on.
  ingress_rules = {
    rule01 = {
      cidr = "0.0.0.0/0"
      desc = "Allow All"
    }
  }

  # Security policy under which the transfer server operates. Generally should not need to change until
  # next policy update, but you might decide to use other security policies for various reasons.
  security_policy_name = "TransferSecurityPolicy-2020-06"

  # Name for the REST API. I recommend leaving at the below but you can name it in whatever manner makes
  # sense for your organization.
  rest_api_name = "custom_idp_transfer_server"




}