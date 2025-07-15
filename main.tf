provider "aws" {
  region = var.aws_region
}

resource "aws_iam_policy" "eks_node_custom_policy" {
  name   = "EKSNodeCustomPolicy"
  policy = file("${path.module}/policies/eks_node_custom_policy.json")
}

# Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  version  = "1.29"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.cluster_security_group_id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Environment = "dev"
    project     = "terraform-aws-eks-clusters"
    Terraform   = "true"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# Node Group IAM Role
resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_defaults" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.eks_node_group.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "eks_node_custom" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = aws_iam_policy.eks_node_custom_policy.arn
}

# Managed Node Groups
resource "aws_eks_node_group" "managed" {
  count = length(var.eks_node_groups)

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.eks_node_groups[count.index].name
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.eks_node_groups[count.index].desired_size
    max_size     = var.eks_node_groups[count.index].max_size
    min_size     = var.eks_node_groups[count.index].min_size
  }

  capacity_type = var.eks_node_groups[count.index].capacity_type

  tags = {
    Environment = "dev"
    project     = "terraform-aws-eks-clusters"
    Terraform   = "true"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_defaults,
    aws_iam_role_policy_attachment.eks_node_custom
  ]
}

# kubectl configure
resource "null_resource" "configure_kubectl" {
  depends_on = [aws_eks_cluster.eks]

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.eks.name}"
  }
}
