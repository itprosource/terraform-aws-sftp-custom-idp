variable "name" {
  type = string
  description = "Name used for identifying resources."
}

variable "cidr" {
  type = string
  description = "CIDR range for VPC."
}

variable "subnet_cidr" {
  type = string
  description = "Subnet CIDR range for SFTP server."
}

variable "az" {
  type = string
  description = "Availability zone for SFTP solution."
}

variable "ingress_rules" {
  type = map(map(any))
  description = "Security group ingress rules for SFTP server."
}

variable "bucket_name" {
  type = string
  description = "Name of s3 bucket used for holding files."
}

variable "security_policy_name" {
  type = string
  description = "Name of security policy to apply to SFTP server."
}

variable "rest_api_name" {
  type = string
  description = "Identifying name for REST API used for iDP."
}

variable "function_name" {
  type = string
  description = "Name of Lambda function which controls iDP process."
}

variable "idp_users" {
  type = map(map(string))
  description = "Map of user values - username, passwords, home directories."
}

variable "region" {
  type = string
  description = "Region in which to host SFTP server."
}