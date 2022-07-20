resource "aws_iam_role" "external_account" {
  name = "external_account"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = "1"
        Principal = {
            AWS = aws_iam_role.github_oidc.arn
        }
      },
    ]
  })
  tags = {
    Name = "external account trust relationship"
  }
}