output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks.name
}

output "update_kubeconfig_command" {
  description = "Command to configure kubectl for this EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.eks.name}"
}
