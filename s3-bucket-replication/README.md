We want to setup bi-directional replication so the source bucket in one account is the destination bucket in the other account and vice versa.
This terraform config applies to a single account, so to complete the loop, we need to run against both sides of the replication.
In each account, we need to setup the following:
1. An IAM role in the source account that allows S3 to assume it and has permissions to read from the source bucket and write to the destination bucket.
2. A replication configuration on the source bucket that specifies the destination bucket and the IAM role.
3. A policy on the source bucket that grants the access to an IAM role in the destination account to complete the loop. Using :root we can manage both directions individually.
