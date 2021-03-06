<div id="top"></div>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/itprosource/terraform-aws-cisco-ngfw-vpc">
  </a>

<h3 align="center">Terraform - Transfer Family SFTP with Customer Identity Provider</h3>

  <p align="center">
    Template which deploys deploys an AWS Transfer Family SFTP server with s3 repository in a security group-controlled VPC environment leveraging a custom identity provider operating through API Gateway, Lambda, and Secrets Manager. 
    <br />
  </p>
</div>

<!-- ABOUT THE PROJECT -->
## About The Project
This module deploys an AWS Transfer Family SFTP server with s3 repository in a security
group-controlled VPC environment leveraging a custom identity provider
operating through API Gateway, Lambda, and Secrets Manager. 

SFTP clients pass their request to the SFTP server endpoint (which may be 
public or private) which is then directed toward API gateway. The formulated
request in API Gateway is then sent to the accompanying Lambda function which 
processes the request against user accounts specified in Secrets Manager.

Files are stored in an encrypted s3 bucket. User accounts can be set up with home directories, if desired.

### Custom Identities
User accounts are stored in Secrets Manager. You can manage user accounts in this template
by updating the idp_users variable in the module. Each key is a single username with 3 values:

1. Password
2. Role
3. HomeDirectory (optional)

There is no need for you to specify the Role - that is done automatically by Terraform.

The HomeDirectory is optional - if you specify a HomeDirectory name, then an s3 folder with
that name will be created for the user and the attribute itself will be automatically 
generated by Terraform. 

There are a few ways you can handle Passwords. These are sensitive values and should NEVER be
plain text within the module. See the following possible use-cases:

1. Runtime Injection - I currently have this template integrated with a Hashicorp Cloud remote 
workspace. I utilized the Variable storage function of the platform to store encrypted Password
variables which are pulled only at runtime and are never exposed. You could theoretically do
something similar with Github Actions, Jenkins, etc. 
2. .Tfvars file - You could store user passwords in a secured tfvars file. You would need to add
tfvars file to the repo before apply in order for that to work, and would need to make sure to 
remove it again. Also, make sure it does not end up in the repo - add to gitignore. 
3. Enter passwords at the Apply stage - You can simply leave the variables blank with no env 
variables and no tfvars. When you run Terraform Apply, it will prompt you to enter user passwords
manually. This is not recommended, as it requires exposing the passwords briefly and requires
entering the passwords manually every time you run Terraform Apply.
4. Hashicorp Vault - I will be testing a deployment of this using Vault. Stay turned for updates.

There are more possibilities but the above are the most straightforward. I am open to suggestions
and new ideas which improve usability and security.

### VPC Security
The transfer server endpoint lives in a VPC and is protected by security group. You can control 
security group ingress rules in the module - simply add as many rules to the mapped variable
as you need. The example template leaves the endpoint set to accept traffic from anywhere, which 
is generally not recommended unless absolutely necessary. Otherwise, filter by IP when possible.

# Future Updates
As time permits, I plan to work on the following updates:
1. Make s3 bucket creation optional, with the option to instead use an existing bucket.
2. Design infrastructure options for pure private deployment - no public IP or extra-AWS traffic.

### Built With

* [Terraform](https://www.terraform.io/)


