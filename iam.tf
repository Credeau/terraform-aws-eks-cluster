# Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name = format("%s-role", local.stack_identifier)
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

# Node group custom policy
resource "aws_iam_role_policy" "eks_node_custom_policy" {
  name = format("%s-policy", local.stack_identifier)
  role = aws_iam_role.eks_node_group.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRegistry",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages",
          "ecr:ListTagsForResource",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "s3:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ],
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "CWACloudWatchServerPermissions"
      },
      {
        "Action" : [
          "ssm:GetParameter"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*",
        "Sid" : "CWASSMServerPermissions"
      },
      {
        "Action" : [
          "iam:CreateServiceLinkedRole"
        ],
        "Condition" : {
          "StringEquals" : {
            "iam:AWSServiceName" : [
              "replication.ecr.amazonaws.com"
            ]
          }
        },
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

# Node Group IAM Role
resource "aws_iam_role" "eks_node_group" {
  name = format("%s-node-group-policy", local.stack_identifier)

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
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.eks_node_group.name
  policy_arn = each.value
}

# VPC CNI IAM Role (IRSA)
data "aws_iam_policy_document" "vpc_cni_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_cni" {
  name               = format("%s-vpc-cni", local.stack_identifier)
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume_role.json

  tags = merge(
    { Name : "${local.stack_identifier}-vpc-cni", ResourceType : "kubernetes" },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# EBS CSI Driver IAM Role (IRSA)
data "aws_iam_policy_document" "ebs_csi_driver_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name               = format("%s-ebs-csi-driver", local.stack_identifier)
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role.json

  tags = merge(
    { Name : "${local.stack_identifier}-ebs-csi-driver", ResourceType : "kubernetes" },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# CloudWatch Observability IAM Role (IRSA)
data "aws_iam_policy_document" "cloudwatch_observability_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch_observability" {
  name               = format("%s-cloudwatch-observability", local.stack_identifier)
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_observability_assume_role.json

  tags = merge(
    { Name : "${local.stack_identifier}-cloudwatch-observability", ResourceType : "kubernetes" },
    local.common_tags
  )
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability" {
  for_each = toset([
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  ])
  role       = aws_iam_role.cloudwatch_observability.name
  policy_arn = each.value
}

# OIDC Provider for EKS
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = merge(
    { Name : "${local.stack_identifier}-oidc", ResourceType : "kubernetes" },
    local.common_tags
  )
}
