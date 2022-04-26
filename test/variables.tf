variable "idp_users" {
  description = "Map of project names to configuration."
  type        = map(map(string))
  default     = {
    secret01 = {
      Password      = "Welcome123!",
      HomeDirectory = "test-directory",
      Role          = "role",
    },
    secret02 = {
      Password      = "Welcome321!",
      HomeDirectory = "directory-test",
      Role          = "test-role",
    }
  }
}

variable "secrets" {
  type = map(string)
  description = ""
  default = {
    secret01 = "test07"
    secret02 = "test08"
  }
}