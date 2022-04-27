# Data source which pulls the AWS account ID and region from Provider.
# Used in various IAM resources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}