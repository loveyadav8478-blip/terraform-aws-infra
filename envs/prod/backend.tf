# REMOTE STATE BACKEND
# S3 for state storage + DynamoDB for locking.
# Solves the "two engineers ran apply at the
# same time and corrupted state" problem.
#
# NOTE: The S3 bucket and DynamoDB table must
# exist BEFORE running `terraform init` here.
# See ../../bootstrap/ for a one-time script,
# or create them manually:
#   aws s3api create-bucket --bucket <your-unique-bucket-name>
#   aws dynamodb create-table --table-name terraform-locks \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --billing-mode PAY_PER_REQUEST

terraform {
  backend "s3" {
    bucket         = "REPLACE-ME-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
