variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group for EKS cluster"
  type        = string
}

variable "eks_node_groups" {
  description = "List of EKS node groups"
  type = list(object({
    name           = string
    desired_size   = number
    max_size       = number
    min_size       = number
    instance_types = list(string)
    capacity_type  = string
  }))
  default = [
    {
      name           = "ng-1"
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      instance_types = ["t3a.small"]
      capacity_type  = "ON_DEMAND"
    }
  ]
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}
