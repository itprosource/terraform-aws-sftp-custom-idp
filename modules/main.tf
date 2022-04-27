provider "aws" {
  region = "us-east-1"
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
  bucket_name = "example-bucket"

  # Optionally, you can create additional s3 folders. These could be used as user-specific home directories,
  # or for a specific use-case: "Billing", "HR", etc. Not required.
  folders = {
    folder01  = "bsmith-home",
    folder02  = "accounting"
  }

  # Name your SFTP user accounts.
  # To add an additional user, enter the next user number (user03, etc) and set it equal to the username.
  # The user number will not appear in AWS, it's ony used by Terraform to order the secrets.
  # Only the username will be used to name the secret.
  secrets = {
    user01    = "bsmith",
    user02    = "svc-acct-app"
  }
  # NOTE: In the current use-case, the secret strings containing password, role, etc are all meant to be
  # input manually. See the README for more info.

  # Create your security group ingress rules. The security group is configured to allow only port 22,
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