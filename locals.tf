locals {
  common_tags = {
    Stage    = var.environment
    Owner    = var.stack_owner
    Team     = var.stack_team
    Pipeline = var.application
    Org      = var.organization
  }

  stack_identifier = format("%s-%s-eks", var.application, var.environment)

  # Derive cluster autoscaler version from cluster version
  # Cluster autoscaler version matches the minor version of Kubernetes
  cluster_autoscaler_version = var.cluster_autoscaler_version != "" ? var.cluster_autoscaler_version : "${var.cluster_version}.0"
}
