output "ecr_repository_url" {
   value = aws_ecr_repository.this.repository_url
 }

output "ecr_repository_name" {
   value = aws_ecr_repository.this.name
 }

output "ecr_push_role_arn" {
  value = aws_iam_role.ecr_push_role.arn
}
