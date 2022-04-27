variable "name" {
  type = string
  description = ""
  default = ""
}

variable "cidr" {
  type = string
  description = ""
  default = ""
}

variable "subnet_cidr" {
  type = string
  description = ""
  default = ""
}

variable "az" {
  type = string
  description = ""
  default = ""
}

variable "ingress_rules" {
  type = map(map(any))
  description = ""
  default = {}
}

variable "bucket_name" {
  type = string
  description = ""
  default = ""
}

variable "bucket_arn" {
  type = string
  description = ""
  default = ""
}

variable "security_policy_name" {
  type = string
  description = ""
  default = ""
}

/*
variable "idp_users" {
  type = map(map(string))
  description = ""
  default = {}
}
*/

variable "secrets" {
  type = map(string)
  description = ""
  default = {}
}

variable "rest_api_name" {
  type = string
  description = ""
  default = ""
}

variable "create_s3_bucket" {
  type = bool
  description = ""
  default = false
}

variable "folders" {
  type = map(string)
  description = ""
  default = {}
}