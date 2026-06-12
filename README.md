#  Terraform AWS Infrastructure

A modular, production-ready Terraform project that provisions a complete AWS backend stack — designed to host containerized **Spring Boot** applications with PostgreSQL, fronted by an **Application Load Balancer (ALB)**, and deployed automatically via **GitHub Actions CI/CD** (keyless OIDC — no static AWS credentials needed).

---

##  Project Structure

```
Terraform_AWS-master/
├── environments/
│   ├── dev/        ← Full dev stack (ALB + ECS + RDS + ECR + IAM + Security)
│   ├── hobby/      ← Minimal personal/hobby stack (fixed small sizing)
│   └── prod/       ← Production stack (deletion protection, larger sizing, HTTPS)
│
└── modules/
    ├── networking/ ← VPC, public subnets, internet gateway, route tables
    ├── alb/        ← Application Load Balancer, target group, HTTP/HTTPS listeners
    ├── ecr/        ← Private Docker registry with lifecycle policies
    ├── iam/        ← ECS roles + GitHub Actions OIDC integration
    ├── security/   ← JWT secrets + DB password in SSM Parameter Store
    ├── database/   ← PostgreSQL RDS with security group chaining
    └── ecs/        ← ECS Fargate cluster, task (Spring Boot only), service
```

---

##  What Gets Created

###  Networking
Custom VPC with public subnets across multiple AZs, internet gateway, and route tables.

### Application Load Balancer (ALB)
- Internet-facing ALB with its own security group
- Target group pointing at Spring Boot containers on **port 8080**
- **HTTP listener (port 80):** forwards directly, or redirects to HTTPS if a cert is provided
- **HTTPS listener (port 443):** created automatically when `certificate_arn` is set
- ALB health checks against `/actuator/health`
- Optional access logs to S3, optional deletion protection

###  ECR (Container Registry)
Private Docker registry with immutable image tags, vulnerability scanning on push, and lifecycle policies (max 5 images, untagged cleaned up after 7 days).

###  IAM & CI/CD
Three roles: GitHub Actions deploy role (OIDC — no static keys), ECS task execution role, ECS task runtime role. GitHub access is locked to your specific repo.

###  Secrets (SSM Parameter Store)
JWT access secret, optional JWT refresh secret, auto-generated DB password, and any number of third-party API keys — all stored as `SecureString` and injected into the container at runtime.

###  Database (RDS PostgreSQL 15)
Firewall-chained so only ECS containers can connect on port 5432. Not publicly accessible. Auto-scales storage up to 100 GiB.

###  ECS Fargate
Single **Spring Boot** container per task (no Nginx — the ALB handles routing). Registers directly with the ALB target group. CloudWatch logs with 7-day retention. All secrets injected from SSM.

---

##  Traffic Flow

```
Internet
   │
   ▼
ALB (port 80 / 443)
   │  health check: /actuator/health
   ▼
ECS Fargate Task
   └── Spring Boot (port 8080)
           │
           ├── SSM Parameter Store (secrets injected at start)
           └── RDS PostgreSQL (port 5432, SG-chained)
```

---

## ⚡ Quick Start

### Prerequisites
- Terraform `>= 1.5.0`
- AWS CLI configured (`aws configure`)
- IAM permissions for VPC, ECS, RDS, ECR, ALB, IAM, SSM

### Deploy

```bash
cd environments/dev

terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### Example `terraform.tfvars` (dev)

```hcl
project_name = "myapp"
environment  = "dev"
aws_region   = "us-east-1"

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]

github_username  = "your-github-username"
github_repo_name = "your-repo-name"

cpu_size      = "512"
memory_size   = "1024"
desired_count = 1

db_instance_class    = "db.t4g.micro"
db_allocated_storage = 20

# Optional: set an ACM cert ARN to enable HTTPS
certificate_arn = ""

enable_dual_tokens = true

app_environment_variables = {
  SERVER_PORT = "8080"
}

third_party_secrets = {
  stripe_key = {
    enabled     = true
    value       = "sk_test_xxxx"
    description = "Stripe API key"
  }
}
```

---

##  Key Outputs

| Output | Description |
|---|---|
| `app_url` | Public URL of your app via the ALB |
| `alb_dns_name` | Raw ALB DNS — use as CNAME for custom domain |
| `alb_zone_id` | Route 53 alias zone ID (prod only) |
| `ecr_repository_url` | Push Docker images here |
| `github_deploy_role_arn` | Paste into GitHub Actions workflow |
| `database_endpoint` | PostgreSQL host (internal) |

---

##  Environments

| Environment | Sizing | Deletion Protection | HTTPS | Desired Tasks |
|---|---|---|---|---|
| `dev` | Configurable | Off | Optional | Configurable |
| `hobby` | 0.25 vCPU / 512 MB | Off | No | 1 |
| `prod` | 1 vCPU / 2 GB default | **On** | Optional (recommended) | 2 |

---

##  Adding S3 in the Future

Create `modules/s3/main.tf`:

```hcl
resource "aws_s3_bucket" "app_storage" {
  bucket = "${var.project_name}-${var.environment}-storage"
}

resource "aws_s3_bucket_versioning" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_storage" {
  bucket = aws_s3_bucket.app_storage.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "app_storage" {
  bucket                  = aws_s3_bucket.app_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

Then add an inline policy to the ECS task role in `modules/iam/main.tf` granting `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` on the bucket, and wire the module in your environment's `main.tf`.

---

##  Cost Estimation

### Dev (minimal)
| Service | Monthly Cost |
|---|---|
| ECS Fargate (0.5 vCPU / 1 GB, 1 task) | ~$15–20 |
| RDS db.t4g.micro + 20 GB | ~$13–16 (free tier yr 1) |
| ALB | ~$16–20 |
| ECR, SSM, CloudWatch | ~$1–2 |
| **Total** | **~$45–60/month** |

### Production (2 tasks, larger DB)
| Service | Monthly Cost |
|---|---|
| ECS Fargate (1 vCPU / 2 GB, 2 tasks) | ~$70–100 |
| RDS db.t3.medium + 50 GB | ~$80–120 |
| ALB | ~$20–30 |
| ECR, SSM, CloudWatch | ~$5–10 |
| **Total** | **~$175–260/month** |

---

##  Capacity

| Config | Concurrent Users | RPS |
|---|---|---|
| dev (0.5 vCPU / 1 GB / 1 task) | ~100–300 | ~50–100 |
| prod default (1 vCPU / 2 GB / 2 tasks) | ~1,000–3,000 | ~300–700 |
| scaled (2 vCPU / 4 GB / 4–8 tasks) | ~8,000–20,000 | ~2,000–5,000 |

---

##  Security Highlights

- ✅ No static AWS credentials — GitHub Actions uses OIDC
- ✅ ECS containers only reachable via ALB (not raw internet)
- ✅ RDS only reachable from ECS containers (SG chaining)
- ✅ All secrets in SSM as `SecureString` (KMS encrypted)
- ✅ ECR immutable image tags + vulnerability scanning
- ✅ HTTPS supported via ACM certificate (HTTP→HTTPS redirect)
- ✅ All resources tagged consistently

---

*Managed by Terraform `>=1.5.0` · AWS Provider `~>5.0`*
