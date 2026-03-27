
variable "source_bucket_name" {
    description = "The name of the source S3 bucket to replicate from"
    type        = string
}

variable "destination_bucket_arn" {
    description = "The ARN of the destination S3 bucket to replicate to"
    type        = string
}

variable "replication_account_id" {
    description = "The AWS account ID of the destination bucket for replication"
    type        = string
}
