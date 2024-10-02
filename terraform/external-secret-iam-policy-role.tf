resource "aws_iam_role" "secrets_manager_role" {
  name = "secrets_manager_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${local.aws_iam_oidc_connect_provider_extract_from_arn}:aud" : "sts.amazonaws.com",
          "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:argocd:external-secret-sa"
        }
      }
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets_manager_policy"
  description = "Policy for accessing AWS Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:*",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DescribeParameters",
          "ssm:GetParameterHistory",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
        ],
        Resource = "*"
      }
    ]
  })
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
  role       = "secrets_manager_role"

  depends_on = [helm_release.argocd]
}

