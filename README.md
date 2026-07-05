# Zero-Downtime, Self-Healing AWS Infrastructure with Terraform

A production-style, multi-environment AWS infrastructure project built with Terraform —
designed to solve the real problems teams hit when running infra at scale, not just
"deploy a server" tutorial code.

## Problems this project solves

| Problem | Solution |
|---|---|
| Manual deployments cause config drift | CI/CD pipeline runs `plan` on PR, `apply` on merge to `main` |
| State file conflicts between engineers | Remote state in S3 with DynamoDB locking |
| No visibility into cost before merging infra changes | Infracost posts a cost diff as a PR comment |
| Security misconfigurations reach production | `tfsec` + `checkov` scan every PR automatically |
| Instance failure causes downtime | Auto Scaling Group + ALB health checks = self-healing |
| Infra changes cause downtime during rollout | ASG rolling `instance_refresh` = zero-downtime deploys |
| A stray `destroy` wipes production data | `prevent_destroy` lifecycle rule on the RDS instance |
| Duplicated code across environments | Modular design (`vpc`, `compute`, `rds`, `iam`) reused across dev/staging/prod |

## Architecture

```
                         Internet
                            |
                      [ Internet GW ]
                            |
                    ------------------
                    |   Public Subnets |  (2 AZs)
                    |        ALB       |
                    ------------------
                            |
                    ------------------
                    |  Private Subnets |  (2 AZs)
                    |   ASG (EC2) x2-4 |
                    ------------------
                            |
                    ------------------
                    |  RDS (Multi-AZ)  |
                    ------------------
```

- **VPC module** — public/private subnets across 2 AZs, single NAT gateway for cost control
- **Compute module** — ALB + Auto Scaling Group with target-tracking scaling and rolling instance refresh
- **RDS module** — Postgres with Multi-AZ (prod), encrypted storage, deletion protection in prod
- **IAM module** — least-privilege instance role (SSM + CloudWatch only, no SSH keys needed)

## Repo structure

```
.
├── modules/
│   ├── vpc/
│   ├── compute/
│   ├── rds/
│   └── iam/
├── envs/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── .github/workflows/terraform.yml
```

Each environment under `envs/` is a root module that wires the shared modules together
with environment-specific sizing (e.g. prod uses `db_multi_az = true` and larger instances).

## CI/CD pipeline

On every pull request:
1. `terraform fmt -check` + `tflint`
2. `tfsec` + `checkov` security scanning
3. `terraform plan` + Infracost cost diff posted as a PR comment

On merge to `main`:
4. `terraform apply` runs automatically against the target environment

## Getting started

### 1. One-time bootstrap (state backend)
Create the S3 bucket + DynamoDB table used for remote state locking, then update
the bucket name in `envs/<env>/backend.tf`:

```bash
aws s3api create-bucket --bucket <your-unique-bucket-name>
aws dynamodb create-table --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

### 2. Configure variables
```bash
cd envs/dev
cp terraform.tfvars.example terraform.tfvars
export TF_VAR_db_username="admin"
export TF_VAR_db_password="<use a secrets manager in real life>"
```

### 3. Deploy
```bash
terraform init
terraform plan
terraform apply
```

### 4. Test
```bash
terraform output alb_dns_name
curl http://<alb_dns_name>
```

## Notes / things I'd add next
- Move DB credentials to AWS Secrets Manager instead of TF variables
- Add WAF in front of the ALB
- Add CloudWatch dashboards + SNS alerting module
- Blue/green deployment option via CodeDeploy for even safer rollouts

---
Built as a hands-on DevOps/IaC learning project. Feedback welcome!
