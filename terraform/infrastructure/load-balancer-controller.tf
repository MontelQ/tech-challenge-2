locals {
  lbc_oidc_issuer = split(
    "oidc-provider/",
    module.eks.oidc_provider_arn
  )[1]
}

resource "aws_iam_policy" "load_balancer_controller" {
  name        = "tech-challenge-2-load-balancer-controller"
  description = "AWS Load Balancer Controller permissions for Tech Challenge 2"

  policy = file(
    "${path.module}/policies/aws-load-balancer-controller.json"
  )
}

resource "aws_iam_role" "load_balancer_controller" {
  name = "tech-challenge-2-load-balancer-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.lbc_oidc_issuer}:aud" = "sts.amazonaws.com"
            "${local.lbc_oidc_issuer}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}

output "load_balancer_controller_role_arn" {
  description = "IAM role used by the AWS Load Balancer Controller"
  value       = aws_iam_role.load_balancer_controller.arn
}
