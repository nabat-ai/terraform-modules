variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "eks_node_group_roles" {
  description = "The ARNs of any EKS node group roles for clusters outside of the account the ECR repo is in. This is used to construct the ECR repository policy."
  type        = list(string)
  default = []
}


variable "repo_name" {
    description = "The name of the github repository. This is used to construct the OIDC condition for the ECR repository policy."
    type        = string
  
}

variable "target_cluster" {
    description = "The name of the EKS cluster to deploy to. This is used to construct the IAM role policy for the EKS deployment role."
    type        = string
}

variable "target_namespace" {
    description = "The name of the Kubernetes namespace to deploy to. This is used to construct the IAM role policy for the EKS deployment role."
    type        = string
}
variable "target_account_id" {
    description = "The AWS account ID of the target EKS cluster. This is used to construct the IAM role policy for the EKS deployment role."
    type        = string
}
