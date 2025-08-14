terraform {
  backend "s3" {
    bucket = "credeautest-terraform-states"
    key    = "di_eks_cluster/prod/terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "eks_cluster" {
  source = "git::https://github.com/Credeau/terraform-aws-eks-cluster/tree/dev?ref=dev%22"  # path to module in repo root

  aws_region                = "ap-south-1"
  cluster_name              = "cluster1"
  vpc_id                    = "vpc-0c460f2a3d5c23337"                       
  subnet_ids                = ["subnet-00e057678764a766e", "subnet-0da8256e3f32d6795"]
  cluster_security_group_id = "sg-06e9ee0a9af082b31"

  eks_node_groups = [
    {
      name           = "ng-1"
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      instance_types = ["t3a.small"]
      capacity_type  = "ON_DEMAND"
    },
    {
      name           = "ng-big-compute"
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      instance_types = ["r6a.xlarge"]
      capacity_type  = "ON_DEMAND"
    }
  ]
}
