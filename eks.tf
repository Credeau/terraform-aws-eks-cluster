# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = local.stack_identifier
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  deletion_protection = var.cluster_deletion_protection

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = var.internal_security_groups
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = merge(
    { Name : local.stack_identifier, ResourceType : "kubernetes" },
    local.common_tags
  )
}

# Custom Node Groups
resource "aws_eks_node_group" "custom" {
  count = length(var.node_groups)

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_groups[count.index].name
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_groups[count.index].instance_types

  scaling_config {
    desired_size = var.node_groups[count.index].desired_size
    max_size     = var.node_groups[count.index].max_size
    min_size     = var.node_groups[count.index].min_size
  }

  capacity_type = var.node_groups[count.index].capacity_type

  tags = merge(
    { Name : var.node_groups[count.index].name, ResourceType : "kubernetes" },
    local.common_tags
  )
}
