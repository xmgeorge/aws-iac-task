# aws-iac-task

A small AWS service provisioned with Terraform, covering a public HTTP compute
service, a serverless function, and CI automation.

## Overview

Two independent public endpoints, both deployed from one Terraform configuration:

| Component | What it is | Endpoint |
| --- | --- | --- |
| **Web service** | An EC2 instance (Ubuntu 24.04) running nginx, serving a simple HTTP page | `http://<ec2-public-ip>` |
| **Serverless** | A Lambda function (Python) returning the current UTC time as JSON, fronted by an API Gateway HTTP API | `https://<api-id>.execute-api.eu-west-2.amazonaws.com/time` |

The code is organised as a root configuration in [`infrastructure/`](infrastructure/)
composed of three local modules (`vpc`, `web`, `serverless`), with remote state
in S3 and a one-time [`bootstrap/`](bootstrap/) config that creates the state
bucket. A GitHub Actions workflow validates, plans, and applies the stack.

Region: **eu-west-2 (London)**.


## Architecture

![Architecture diagram](docs/architecture.png)

_Source: [`docs/architecture.dot`](docs/architecture.dot), rendered to PNG with Graphviz (`dot -Tpng`)._

## Repository layout

```
.
├── bootstrap/              # one-time: creates the S3 state bucket (local state)
├── infrastructure/         # the stack (remote state in S3)
│   ├── backend.tf          # S3 backend + native lockfile
│   ├── main.tf             # module composition
│   ├── providers.tf        # AWS provider + default tags
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf         # Terraform + provider version constraints
│   └── modules/
│       ├── vpc/            # VPC, IGW, public subnets, routing
│       ├── web/            # security group, IAM/SSM, EC2 + nginx user-data
│       └── serverless/     # Lambda + API Gateway HTTP API
└── .github/workflows/
    ├── terraform.yml       # validate / plan / apply
    └── destroy.yml         # manual teardown (typed confirmation)
```

## Prerequisites

- An AWS account and credentials (`aws configure`, or exported env vars)
- **Terraform >= 1.10** (the backend uses native S3 state locking, `use_lockfile`)
- AWS CLI (for the bootstrap step)

## Deployment

### 1. Bootstrap the state bucket (once per account)

The state bucket must exist before the main config can use it as a backend, so
`bootstrap/` runs with local state and is applied by hand once.

```bash
cd bootstrap
terraform init
terraform apply
terraform output state_bucket_name   # e.g. aws-iac-task-tfstate-<account-id>
```

### 2. Point the backend at the bucket

Set the bucket name from the output above in
[`infrastructure/backend.tf`](infrastructure/backend.tf).

### 3. Deploy the stack

```bash
cd ../infrastructure
terraform init      # connects to the S3 backend
terraform apply
```

Terraform prints the endpoints on completion:

```bash
terraform output web_url         # http://<ec2-public-ip>
terraform output lambda_api_url  # https://<api-id>.execute-api.eu-west-2.amazonaws.com/time
```

### 4. Test

```bash
curl "$(terraform output -raw web_url)"          # HTML page from nginx on EC2
curl "$(terraform output -raw lambda_api_url)"   # {"service":"current-time","current_time_utc":"..."}
```

> The EC2 page needs a minute after apply while user-data installs nginx.

### 5. Clean up

```bash
terraform destroy                 # in infrastructure/
# and, if you no longer need remote state:
cd ../bootstrap && terraform destroy
```

## CI/CD

[`.github/workflows/terraform.yml`](.github/workflows/terraform.yml):

| Job | Trigger | Purpose | AWS creds |
| --- | --- | --- | --- |
| `validate` | every push / PR | `terraform fmt -check` + `validate` (`-backend=false`) | none |
| `plan` | pull requests | speculative `terraform plan` for review | yes |
| `apply` | manual (`workflow_dispatch`) | `plan -out=tfplan` then `apply tfplan` — applies exactly the reviewed plan | yes |
| `destroy` | manual (`workflow_dispatch`) | tears down the stack; requires typing `destroy` to confirm (separate `destroy.yml`) | yes |

Credentials come from the repo secrets `AWS_ACCESS_KEY_ID` and
`AWS_SECRET_ACCESS_KEY`. The `validate` job needs no credentials, so it runs on
every change regardless. To run `apply`, the workflow must be on the default
branch (GitHub only shows *Run workflow* / fires `workflow_dispatch` for the
default branch).

## Remote state

- **S3 bucket** — versioned and encrypted (AES256), with all public access
  blocked (see `bootstrap/`).
- **Locking** — the S3 backend's native lockfile (`use_lockfile = true`,
  Terraform >= 1.10), so no DynamoDB table is required.

## Security practices applied

- **No SSH** — the EC2 instance opens no port 22 and has no key pair; admin
  access is via **SSM Session Manager** (least-privilege instance role).
- **Encrypted EBS** root volume; **encrypted, private, versioned** state bucket.
- **Security group** allows only inbound HTTP (:80), configurable via
  `allowed_http_cidrs`.
- **Least-privilege IAM** — the Lambda role has only the basic-execution
  (CloudWatch Logs) policy; the EC2 role has only SSM core.
- **Scoped Lambda invoke** — API Gateway may invoke the function, nothing else.
- No secrets in code; credentials supplied at runtime (CLI profile / CI secrets).

## Assumptions

- A single, publicly reachable EC2 instance is acceptable for the demo (no load
  balancer, to stay within the Free Tier).
- HTTP (not HTTPS) is fine for the EC2 endpoint at this scope; TLS would be
  terminated at a load balancer / CloudFront in production.
- `t3.micro` and the Lambda/API Gateway free-tier allowances keep cost at or
  near zero. Free-tier instance eligibility can vary by account/region.
- The default `allowed_http_cidrs` is `0.0.0.0/0`; lock it to your own IP for a
  private demo.

## Improving this for production

**Security**
- Put the EC2 service behind an Application Load Balancer with **HTTPS** (ACM
  cert) and move instances into **private subnets** (NAT for egress).
- Switch CI from long-lived access keys to **GitHub OIDC role assumption** (no
  stored credentials) and scope the role to least privilege.
- Add a **WAF** in front of the ALB / API Gateway; enable GuardDuty, Config,
  and CloudTrail.
- Gate `apply` behind a **protected `production` environment** requiring manual
  approval, and apply an uploaded plan artifact.

**Scalability**
- Replace the single instance with an **Auto Scaling Group** across multiple AZs
  behind the ALB; scale on CPU / request metrics.
- For the container path, ECS Fargate or EKS instead of EC2.
- The Lambda + HTTP API tier already scales horizontally by default.

**Reliability**
- Multi-AZ everything (the network is already multi-AZ ready).
- Health checks + automatic instance replacement via the ASG.
- Store state with versioning (done) and add CI **drift detection**
  (`terraform plan -detailed-exitcode` on a schedule).
- Centralised logging/metrics/alarms (CloudWatch dashboards + alerts).
```