## v1.0.0 - Initial Release

First stable release of the terraform-aws-eks-cluster module for deploying production-ready EKS clusters on AWS.

### Features

**Core Infrastructure**
- EKS cluster provisioning with configurable Kubernetes versions
- Multi-node group support with flexible instance types and capacity types (On-Demand/Spot)
- Cluster deletion protection enabled by default
- IAM OIDC provider integration for service account authentication

**Add-ons & Drivers**
- VPC CNI with automatic version detection
- EBS CSI Driver for persistent volume support
- EFS CSI Driver for shared file system storage
- CloudWatch Observability for monitoring and logging

**Autoscaling**
- Cluster Autoscaler with automatic deployment and RBAC configuration
- Auto-derived version matching based on cluster version
- IAM roles for service accounts (IRSA) integration

**Access Management**
- Configurable cluster access via principal ARNs (IAM users/roles)
- API and ConfigMap authentication modes
- Admin policy associations for authorized principals

**Networking**
- Private subnet deployment
- Configurable security groups
- Public and private endpoint access

### Usage

See the [example](./example) directory for a complete implementation reference.
