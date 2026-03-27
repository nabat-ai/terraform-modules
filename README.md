# Terraform Modules

Repository for shared terraform modules

## s3-bucket-replication

Used to set up bucket replication in an account. 

Rather than trying to control the resources in both accounts, this module assumes you have environments for each end of the replication pipe.

Uses root iam deference to allow the mirror account to manage permissions.

example

```hcl
module "two_way_bucket_replication" {
    source = "git::https://github.com/nabat-ai/terraform-modules.git//s3-bucket-replication?ref=s3-bucket-replication/1.0.0"
    
    source_bucket_name = "my-source-bucket
    destination_bucket_arn = "arn:aws:s3:::destination-bucket"
    replication_account_id = 12345689012
}

```

