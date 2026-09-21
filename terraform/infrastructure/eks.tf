variable "admin_cidr" {
  description = "Current CloudShell outbound IPv4 address with /32."
  type        = string

  validation {
    condition = (
      can(cidrnetmask(var.admin_cidr)) &&
      endswith(var.admin_cidr, "/32")
    )
    error_message = "Provide one IPv4 address with a /32 suffix."
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.25.1"

  name               = "tech-challenge-2"
  kubernetes_version = "1.36"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_private_access      = true
  endpoint_public_access       = true
  endpoint_public_access_cidrs = [var.admin_cidr]

  enable_cluster_creator_admin_permissions = true

  upgrade_policy = {
    support_type = "STANDARD"
  }

  cloudwatch_log_group_retention_in_days = 7

  addons = {
    vpc-cni = {
      before_compute = true
    }

    eks-pod-identity-agent = {
      before_compute = true
    }

    kube-proxy = {}
    coredns    = {}
  }

  eks_managed_node_groups = {
    workers = {
      name           = "tc2-workers"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      desired_size = 1
      max_size     = 4

      iam_role_attach_cni_policy = true
    }
  }

}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
