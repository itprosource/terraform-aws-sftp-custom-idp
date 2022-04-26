provider "aws" {
  region = "us-east-1"
}

resource "aws_secretsmanager_secret" "secret" {
  for_each = var.secrets
  name = each.value
}

resource "aws_secretsmanager_secret_version" "secrets" {
  for_each      = var.idp_users
  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = jsonencode(each.value)
}
