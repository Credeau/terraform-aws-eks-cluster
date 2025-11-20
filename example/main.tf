module "eks_cluster" {
  source = "git::https://github.com/credeau/terraform-aws-eks-cluster.git?ref=v1.2.0" # path to module in repo root

  application  = "mobile-forge"
  environment  = "prod"
  region       = "ap-south-1"
  stack_owner  = "tech@credeau.com"
  stack_team   = "devops"
  organization = "credeau"

  vpc_id                   = "vpc-00000000000000000"
  private_subnet_ids       = ["subnet-00000000000000000"]
  internal_security_groups = ["sg-00000000000000000"]

  cluster_deletion_protection = true
  cluster_version             = "1.34"
  node_groups = [
    {
      name           = "ng-regular"
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      instance_types = ["t3a.small"]
      capacity_type  = "ON_DEMAND"
    },
    {
      name           = "ng-big-memory"
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      instance_types = ["r6a.xlarge"]
      capacity_type  = "ON_DEMAND"
    },
  ]
  cluster_access_principal_arns = ["arn:aws:iam::account_id:role/aws-reserved/sso.amazonaws.com/ap-south-1/sso_role_name"]
  enable_cluster_autoscaler     = true
  cluster_autoscaler_version    = "" # Will assign automatically if left empty
}

output "eks_cluster" {
  value = module.eks_cluster
}

