# ci-ecr-push

Creates an ECR repository along with a GitHub Actions OIDC IAM role scoped to just the permissions needed to push images to it.

This lets a GitHub Actions workflow in a given repo authenticate to AWS via OIDC (no long-lived credentials) and push/tag images to its own ECR repository.

Includes a lifecycle policy that:
- Keeps the latest 5 `prod`-tagged images
- Removes untagged images after 1 day
- Removes `review`-tagged images after 30 days
- Removes `cache`-tagged images after 15 days
- Removes any other unmatched images after 14 days

## Assumptions

- A GitHub Actions OIDC provider (`token.actions.githubusercontent.com`) already exists in the account.
- The GitHub repo pushing images is under the `nabat-ai` GitHub org.

## Usage

```hcl
module "ci_ecr_push" {
  source = "git::https://github.com/nabat-ai/terraform-modules.git//ci-ecr-push"

  repository_name = "my-service"
  repo_name       = "my-service" # GitHub repo name, used to scope the OIDC trust policy
}
```

Configure the resulting IAM role ARN as the role assumed by the `aws-actions/configure-aws-credentials` step in the GitHub Actions workflow for that repo.

## Inputs

| Name                    | Description                                                                                | Type   | Default    | Required |
| ----------------------- | -------------------------------------------------------------------------------------------- | ------ | ---------- | :------: |
| `repository_name`       | The name of the ECR repository                                                               | string | n/a        |   yes    |
| `repo_name`             | The name of the GitHub repository. Used to scope the OIDC condition on the ECR push role.    | string | n/a        |   yes    |
| `image_tag_mutability`  | Tag mutability for the repository. Valid values are `MUTABLE` or `IMMUTABLE`.                 | string | `"MUTABLE"`|    no    |
| `scan_on_push`          | Whether to scan images for vulnerabilities on push.                                          | bool   | `false`    |    no    |

## Outputs

| Name             | Description                  |
| ---------------- | ----------------------------- |
| `repository_url` | The URL of the ECR repository |
| `repository_name` | The URL of the ECR repository |
