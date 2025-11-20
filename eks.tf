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

resource "aws_eks_access_entry" "sso_user" {
  count = length(var.cluster_access_principal_arns)

  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.cluster_access_principal_arns[count.index]
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "sso_user" {
  count = length(var.cluster_access_principal_arns)

  cluster_name  = aws_eks_cluster.eks.name
  principal_arn = var.cluster_access_principal_arns[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# Get latest VPC CNI version
data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}

# VPC CNI Add-on
resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "vpc-cni"
  addon_version            = data.aws_eks_addon_version.vpc_cni.version
  service_account_role_arn = aws_iam_role.vpc_cni.arn
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(
    { Name : "${local.stack_identifier}-vpc-cni", ResourceType : "kubernetes" },
    local.common_tags
  )
}

# Get latest EBS CSI Driver version
data "aws_eks_addon_version" "ebs_csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}

# EBS CSI Driver Add-on
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi_driver.version
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  tags = merge(
    { Name : "${local.stack_identifier}-ebs-csi-driver", ResourceType : "kubernetes" },
    local.common_tags
  )
}

# Get latest CloudWatch Observability version
data "aws_eks_addon_version" "cloudwatch_observability" {
  addon_name         = "amazon-cloudwatch-observability"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}

# CloudWatch Observability Add-on
resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "amazon-cloudwatch-observability"
  addon_version            = data.aws_eks_addon_version.cloudwatch_observability.version
  service_account_role_arn = aws_iam_role.cloudwatch_observability.arn

  configuration_values = jsonencode({
    agent = {
      config = {
        logs = {
          metrics_collected = {
            application_signals = {
              enabled = var.enable_cloudwatch_application_signals
            }
          }
        }
      }
    }
  })

  tags = merge(
    { Name : "${local.stack_identifier}-cloudwatch-observability", ResourceType : "kubernetes" },
    local.common_tags
  )
}
