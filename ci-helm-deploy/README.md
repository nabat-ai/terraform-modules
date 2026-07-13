# ci-helm-deploy

Creates a GitHub Actions OIDC IAM role scoped to deploy an application into a specific EKS cluster and namespace, and grants the target cluster's node group roles pull access to the application's ECR repository.

This lets a GitHub Actions workflow authenticate to AWS via OIDC (no long-lived credentials), then deploy to EKS (e.g. via `helm upgrade` or `kubectl apply`) against a specific cluster/namespace, while the cluster's nodes are able to pull the pushed image from ECR.

The module:
- Attaches a repository policy to an existing ECR repository, allowing the given EKS node group roles to `BatchGetImage`, `DescribeImages`, and `GetDownloadUrlForLayer`.
- Creates an IAM role (`<repository_name>-app-deploy-role`) assumable via the GitHub Actions OIDC provider, scoped to the given GitHub repo.
- Grants that role `eks:DescribeCluster` / `eks:AccessKubernetesApi` on the target cluster.
- Registers an EKS access entry for the role and associates the `AmazonEKSClusterAdminPolicy` access policy, scoped to the target namespace.

## Assumptions

- A GitHub Actions OIDC provider (`token.actions.githubusercontent.com`) already exists in the account.
- The GitHub repo deploying the application is under the `nabat-ai` GitHub org.
- The ECR repository (`repository_name`) already exists — this module only attaches a repository policy to it, it does not create the repository (see [ci-ecr-push](../ci-ecr-push)).
- `eks_node_group_roles` only needs to include node group roles for clusters *outside* the account the ECR repo lives in — same-account node group roles already have pull access via the account's default ECR permissions.
- The target EKS cluster's authentication mode supports IAM access entries (`API` or `API_AND_CONFIG_MAP`).

## Usage

```hcl
module "ci_helm_deploy" {
  source = "git::https://github.com/nabat-ai/terraform-modules.git//ci-helm-deploy"

  repository_name      = "my-service"
  repo_name            = "my-service"       # GitHub repo name, used to scope the OIDC trust policy
  target_cluster       = "my-eks-cluster"
  target_namespace     = "my-service"
  eks_node_group_roles  = [
    "arn:aws:iam::111111111111:role/other-account-eks-node-group-role",
  ]
}
```

Configure the resulting IAM role ARN as the role assumed by the `aws-actions/configure-aws-credentials` step in the GitHub Actions workflow that deploys the application.

## Inputs

| Name                    | Description                                                                                                          | Type         | Default | Required |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------------ | ------- | :------: |
| `repository_name`       | The name of the ECR repository. Also used to name the deployment IAM role (`<repository_name>-app-deploy-role`).       | string       | n/a     |   yes    |
| `repo_name`              | The name of the GitHub repository. Used to scope the OIDC trust condition on the deployment role.                       | string       | n/a     |   yes    |
| `eks_node_group_roles`  | ARNs of EKS node group roles, for clusters outside the account the ECR repo is in, that need pull access to the repository. | list(string) | n/a     |   yes    |
| `target_cluster`         | The name of the EKS cluster to deploy to.                                                                               | string       | n/a     |   yes    |
| `target_namespace`      | The name of the Kubernetes namespace to deploy to.                                                                      | string       | n/a     |   yes    |

## Outputs

| Name                      | Description                                                            |
| ------------------------- | ------------------------------------------------------------------------ |
| `eks_deployment_role_arn` | The ARN of the IAM role GitHub Actions assumes to deploy to the cluster. |
