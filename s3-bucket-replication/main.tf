# 1. IAM Role and Policy for Replication
data "aws_s3_bucket" "source_bucket" {
  bucket = var.source_bucket_name
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "replication" {
  name               = "${var.source_bucket_name}-replication-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [data.aws_s3_bucket.source_bucket.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${data.aws_s3_bucket.source_bucket.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${var.destination_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "replication" {
    name = "${var.source_bucket_name}-replication-role-policy"
    role = aws_iam_role.replication.id
    policy = data.aws_iam_policy_document.replication.json
}


# 2. Replication Configuration on Source Bucket
resource "aws_s3_bucket_replication_configuration" "replication" {

  role   = aws_iam_role.replication.arn
  bucket = var.source_bucket_name

  rule {
    id = "data-backup"

    status = "Enabled"

    destination {
      bucket        = var.destination_bucket_arn
    }
  }
}


# 3. Bucket Policy to Allow Access from Destination Account
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    # Defer to the replication role in the destination account to have permissions to replicate back to the source bucket to complete the 2-way link.
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.replication_account_id}:root"]
    }

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    # Confusing because it says source, but this is a replication destination
    # for the replication role arn in another account. 
    # This completes the bi-directional replication loop.
    resources = [
      "${data.aws_s3_bucket.source_bucket.arn}/*"
    ]
  }
}
