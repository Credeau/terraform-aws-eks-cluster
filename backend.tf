# Configure the remote backend here
terraform {
  backend "s3" {
    bucket = "credeautest-terraform-states"          # change this as per the AWS account
    key    = "di_eks_cluster/prod/terraform.tfstate" # do not touch this!
    region = "ap-south-1"
  }
}
