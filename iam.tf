resource "aws_iam_role_policy" "eks_node_custom_policy" {
  name = format("%s-policy", local.stack_identifier)
  role = aws_iam_role.main.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
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
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": [
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
        "Effect": "Allow",
        "Resource": "*",
        "Sid": "CWACloudWatchServerPermissions"
      },
      {
        "Action": [
          "ssm:GetParameter"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*",
        "Sid": "CWASSMServerPermissions"
      },
      {
        "Action": [
          "iam:CreateServiceLinkedRole"
        ],
        "Condition": {
          "StringEquals": {
            "iam:AWSServiceName": [
              "replication.ecr.amazonaws.com"
            ]
          }
        },
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

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


resource "aws_iam_role_policy_attachment" "eks_node_custom" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = aws_iam_policy.eks_node_custom_policy.arn
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
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])
  role       = aws_iam_role.eks_node_group.name
  policy_arn = each.value
}