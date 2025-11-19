# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = local.stack_identifier
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn

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

resource "aws_launch_template" "custom" {
  name                   = format("%s-ng", local.stack_identifier)
  update_default_version = true

  network_interfaces {
    security_groups       = var.internal_security_groups
    delete_on_termination = true
  }

  # Additional EBS volume for persistent data
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = var.data_volume_size
      volume_type           = var.data_volume_type
      encrypted             = true
      delete_on_termination = var.delete_data_volume_on_termination
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name : format("%s-ng", local.stack_identifier),
        ResourceType : "server"
      }
    )
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = merge(
      local.common_tags,
      {
        Name : format("%s-ng", local.stack_identifier),
        ResourceType : "network"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.common_tags,
      {
        Name : format("%s-ng", local.stack_identifier),
        ResourceType : "storage"
      }
    )
  }
}

# Custom Node Groups
resource "aws_eks_node_group" "custom" {
  count = length(var.node_groups)

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_groups[count.index].name
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_groups[count.index].desired_size
    max_size     = var.node_groups[count.index].max_size
    min_size     = var.node_groups[count.index].min_size
  }

  launch_template {
    id      = aws_launch_template.custom.id
    version = "$Latest"
  }

  capacity_type = var.node_groups[count.index].capacity_type

  tags = merge(
    { Name : var.node_groups[count.index].name, ResourceType : "kubernetes" },
    local.common_tags
  )
}

data "aws_eks_addon_version" "ebs_csi" {
  count = 0

  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}

resource "aws_eks_addon" "ebs_csi_driver" {
  count = 0

  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi[0].version

  depends_on = [
    aws_eks_node_group.custom
  ]

  tags = local.common_tags
}
