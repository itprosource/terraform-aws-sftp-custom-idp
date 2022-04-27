resource "aws_secretsmanager_secret" "secret" {
  for_each = var.idp_users
  name = "SFTP/${each.key}"
}
/*
resource "aws_secretsmanager_secret_version" "secrets" {
  for_each      = var.secrets
  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = jsonencode(each.value)
}
*/
resource "aws_secretsmanager_secret_version" "secrets" {
  for_each      = var.idp_users
  secret_id     = aws_secretsmanager_secret.secret[each.key].id
  secret_string = jsonencode({
    "Password": "${each.value["Password"]}", "HomeDirectory" : "/${aws_s3_bucket.s3.id}/${each.value["HomeDirectory"]}", "Role" : "${aws_iam_role.sftp_role.arn}"
  })
}
