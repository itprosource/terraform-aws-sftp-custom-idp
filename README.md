# terraform-aws-pw-auth-sftp
This module deploys an AWS Transfer Family SFTP server with s3 repository in a security
group-controlled VPC environment leveraging a custom identity provider
operating through API Gateway, Lambda, and Secrets Manager. 

SFTP clients pass their request to the SFTP server endpoint (which may be 
public or private) which is then directed toward API gateway. The formulated
request in API Gateway is then sent to the accompanying Lambda function which 
processes the request against user accounts specified in Secrets Manager.

Files are stored in s3. User accounts can be set up with home directories, if desired.

### Custom Identities
As of the current version of this template, only the username is created - 
meaning, the Secret itself. This template does not create any of the necessary
Secret Strings to log in, which are: 

1. Password
2. Role
3. HomeDirectory (optional, not required)

After the template is deployed, you will need to access the Secret(s) in Secrets Manager
and manually enter the above Secret Strings. 