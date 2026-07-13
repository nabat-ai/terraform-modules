
variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Valid values are 'MUTABLE' or 'IMMUTABLE'."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
    description = "Whether to scan images on push. Valid values are true or false."
    type        = bool
    default     = false
  
}

variable "repo_name" {
    description = "The name of the github repository. This is used to construct the OIDC condition for the ECR repository policy."
    type        = string
  
}
