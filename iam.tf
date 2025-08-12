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


resource "aws_iam_role_policy_attachment" "eks_node_custom" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = aws_iam_policy.eks_node_custom_policy.arn
}