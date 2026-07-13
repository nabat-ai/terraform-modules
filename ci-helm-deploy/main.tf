data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:nabat-ai/${var.repo_name}:*"]
    }
  }
}

resource "aws_ecr_repository_policy" "this" {
  count = length(var.eks_node_group_roles) > 0 ? 1 : 0
  # Need to add the node group roles for each EKS cluster outside of the account the ECR repo is in
  repository = var.repository_name
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EKSPullImage",
      "Effect": "Allow",
      "Principal": {
        "AWS": var.eks_node_group_roles
      },
      "Action": [
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
})
}


resource "aws_iam_role" "eks_deployment_role" {
  name               = "${var.repository_name}-app-deploy-role"
  description        = "A role to be given edit permissions in EKS to allow it to deploy applications"
  assume_role_policy = data.aws_iam_policy_document.github_oidc_assume_role.json
}


# This policy allows the EKS deployment role to describe the cluster and access the Kubernetes API for the target clusters specified in the variable.
resource "aws_iam_role_policy" "this" {

  name = "eks-app-deploy"
  role = aws_iam_role.eks_deployment_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "eks:DescribeCluster",
          "eks:AccessKubernetesApi"
        ],
        "Resource" : [
          "arn:aws:eks:*:${var.target_account_id}:cluster/${var.target_cluster}" 
        ]
      }
    ]
  })

}

resource "aws_eks_access_entry" "this" {
  cluster_name      = var.target_cluster
  principal_arn     = aws_iam_role.eks_deployment_role.arn
  kubernetes_groups = ["cluster-admins"]
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  cluster_name  = var.target_cluster
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_role.eks_deployment_role.arn

  access_scope {
    type = "namespace"
    namespaces = [ var.target_namespace ]

  }
}
