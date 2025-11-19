# terraform-aws-eks-cluster
Terraform module for deploying and managing AWS infrastructure for Kubernetes cluster on EKS.


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eks_access_entry.sso_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.sso_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_cluster.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_role.eks_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eks_node_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.eks_node_custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.eks_cluster_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eks_node_group_defaults](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | application name to refer and mnark across the module | `string` | `"default"` | no |
| <a name="input_cluster_access_principal_arns"></a> [cluster\_access\_principal\_arns](#input\_cluster\_access\_principal\_arns) | list of pricncipal arns (role or user) to provide cluster access | `list(string)` | `[]` | no |
| <a name="input_cluster_deletion_protection"></a> [cluster\_deletion\_protection](#input\_cluster\_deletion\_protection) | protect cluster from accidental deletion | `bool` | `true` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | k8s cluster version | `string` | `"1.34"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | environment type | `string` | `"dev"` | no |
| <a name="input_internal_security_groups"></a> [internal\_security\_groups](#input\_internal\_security\_groups) | list of internal access security group ids | `list(string)` | `[]` | no |
| <a name="input_node_groups"></a> [node\_groups](#input\_node\_groups) | List of node groups | <pre>list(object({<br>    name           = string<br>    desired_size   = number<br>    max_size       = number<br>    min_size       = number<br>    instance_types = list(string)<br>    capacity_type  = string<br>  }))</pre> | <pre>[<br>  {<br>    "capacity_type": "ON_DEMAND",<br>    "desired_size": 1,<br>    "instance_types": [<br>      "t3a.small"<br>    ],<br>    "max_size": 1,<br>    "min_size": 1,<br>    "name": "ng-regular"<br>  },<br>  {<br>    "capacity_type": "ON_DEMAND",<br>    "desired_size": 1,<br>    "instance_types": [<br>      "r6a.xlarge"<br>    ],<br>    "max_size": 1,<br>    "min_size": 1,<br>    "name": "ng-big-memory"<br>  }<br>]</pre> | no |
| <a name="input_organization"></a> [organization](#input\_organization) | organization name | `string` | `"credeau"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | list of private subnet ids to use | `list(string)` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | aws region to use | `string` | `"ap-south-1"` | no |
| <a name="input_stack_owner"></a> [stack\_owner](#input\_stack\_owner) | owner of the stack | `string` | `"tech@credeau.com"` | no |
| <a name="input_stack_team"></a> [stack\_team](#input\_stack\_team) | team of the stack | `string` | `"devops"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | vpc id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | EKS cluster name |
| <a name="output_update_kubeconfig_command"></a> [update\_kubeconfig\_command](#output\_update\_kubeconfig\_command) | Command to configure kubectl for this EKS cluster |
<!-- END_TF_DOCS -->