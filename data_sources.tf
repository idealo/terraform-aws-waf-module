
#arn:aws:iam::487896879419:role/sc-terraform-product-launch-role-domain-delegator

data "aws_caller_identity" "current" {}


data "aws_secretsmanager_secret" "secret_header" {
  provider   = aws.fm
  arn        = var.secret_header_arn
  depends_on = [aws_secretsmanager_secret.secret_header]
}

data "aws_secretsmanager_secret_version" "secret_header_current" {
  provider      = aws.fm
  depends_on    = [aws_secretsmanager_secret_version.secret_header]
  secret_id     = data.aws_secretsmanager_secret.secret_header.arn
  version_stage = "AWSCURRENT"
}

data "aws_secretsmanager_secret_version" "secret_header_previous" {
  provider      = aws.fm
  depends_on    = [aws_secretsmanager_secret_version.secret_header]
  secret_id     = data.aws_secretsmanager_secret.secret_header.arn
  version_stage = "AWSPREVIOUS"
}