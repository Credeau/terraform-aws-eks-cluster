# -----------------------------------------------
# Application and Environment Variables
# -----------------------------------------------
variable "application" {
  type        = string
  description = "application name to refer and mnark across the module"
  default     = "default"
}

variable "environment" {
  type        = string
  description = "environment type"
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod", "uat"], var.environment)
    error_message = "Environment must be one of: dev, prod, or uat."
  }
}

variable "region" {
  type        = string
  description = "aws region to use"
  default     = "ap-south-1"
}

variable "stack_owner" {
  type        = string
  description = "owner of the stack"
  default     = "tech@credeau.com"
}

variable "stack_team" {
  type        = string
  description = "team of the stack"
  default     = "devops"
}

variable "organization" {
  type        = string
  description = "organization name"
  default     = "credeau"
}

# -----------------------------------------------
# Networking Variables
# -----------------------------------------------

variable "vpc_id" {
  description = "vpc id"
  type        = string
}


variable "private_subnet_ids" {
  type        = list(string)
  description = "list of private subnet ids to use"
}

variable "internal_security_groups" {
  type        = list(string)
  description = "list of internal access security group ids"
  default     = []
}

# -----------------------------------------------
# Cluster Configuration Variables
# -----------------------------------------------

variable "cluster_deletion_protection" {
  type        = bool
  description = "protect cluster from accidental deletion"
  default     = true
}

variable "cluster_version" {
  type        = string
  description = "k8s cluster version"
  default     = "1.34"
}

variable "node_groups" {
  description = "List of node groups"
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
      name           = "ng-regular"
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      instance_types = ["t3a.small"]
      capacity_type  = "ON_DEMAND"
    },
    {
      name           = "ng-big-memory"
      desired_size   = 1
      max_size       = 1
      min_size       = 1
      instance_types = ["r6a.xlarge"]
      capacity_type  = "ON_DEMAND"
    },
  ]
}
