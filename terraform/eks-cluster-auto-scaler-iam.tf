# Resource: IAM Policy for Cluster Autoscaler
resource "aws_iam_policy" "cluster_autoscaler_iam_policy" {
  name        = "${local.name}-AmazonEKSClusterAutoscalerPolicy"
  path        = "/"
  description = "EKS Cluster Autoscaler Policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeInstanceTypes"
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      }
    ]
  })
}

# Resource: IAM Role for Cluster Autoscaler
## Create IAM Role and associate it with Cluster Autoscaler IAM Policy
resource "aws_iam_role" "cluster_autoscaler_iam_role" {
  name = "${local.name}-cluster-autoscaler"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "${aws_iam_openid_connect_provider.oidc_provider.arn}"
        }
        Condition = {
          StringEquals = {
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:aud" : "sts.amazonaws.com",
            "${local.aws_iam_oidc_connect_provider_extract_from_arn}:sub" : "system:serviceaccount:argocd:cluster-autoscaler"
          }
        }
      },
    ]
  })

  tags = {
    tag-key = "cluster-autoscaler"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}


# Associate IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "cluster_autoscaler_iam_role_policy_attach" {
  policy_arn = aws_iam_policy.cluster_autoscaler_iam_policy.arn
  role       = aws_iam_role.cluster_autoscaler_iam_role.name
}

output "cluster_autoscaler_iam_role_arn" {
  description = "Cluster Autoscaler IAM Role ARN"
  value       = aws_iam_role.cluster_autoscaler_iam_role.arn
}
