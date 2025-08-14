output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = var.cluster_security_group_id
}

output "custom_node_policy_arn" {
  description = "ARN of the custom node IAM policy"
  value       = aws_iam_policy.eks_node_custom_policy.arn
}

output "update_kubeconfig_command" {
  description = "Command to configure kubectl for this EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.eks.name}"
}
