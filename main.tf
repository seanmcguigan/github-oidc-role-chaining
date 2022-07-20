resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  tags = {
    "Name" = "github"
  }
}

resource "aws_iam_role" "github_oidc" {
  name = "github_oidc"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = "1"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Condition = {
          StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub" = "repo:seanmcguigan/github-oidc-role-chaining:ref:refs/heads/main" }
        }
      },
    ]
  })
  tags = {
    Name = "Github OIDC trust relationship"
  }
}
# https://aws.amazon.com/premiumsupport/knowledge-center/cross-account-access-iam/
resource "aws_iam_policy" "github_oidc" {
  name        = "github_oidc"
  path        = "/"
  description = "mock admin"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.external_account.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_oidc" {
  role       = aws_iam_role.github_oidc.name
  policy_arn = aws_iam_policy.github_oidc.arn
}
