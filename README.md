# Virto Commerce on AWS (Terraform + Floci)

Terraform code that builds the AWS architecture for Virto Commerce on the **Floci emulator**.

> Nothing is deployed to real AWS. This is tested only on Floci (a local emulator).

## What gets created

| Module | Resources |
|---|---|
| network | VPC, public/private subnets, NAT, security groups |
| data | RDS PostgreSQL, Secrets Manager, EFS |
| compute | ECR, IAM roles, ALB, ECS on EC2 (ASG) |
| frontend | S3 (private) + CloudFront |
| monitoring | SNS + CloudWatch alarms |

## Project Structure

```
floci/        Floci docker-compose + env.sh
scripts/      floci-up.sh, validate.sh, floci-down.sh
terraform/
  envs/floci/ Floci-specific settings
  modules/    network, data, compute, frontend, monitoring
images/       screenshots
```

## 📁 Files Structure

```text
virto-terraform-floci/
├── floci/
│   ├── docker-compose.yml
│   └── env.sh
├── images/
│   ├── Floci.png
│   ├── initialization.png
│   ├── terraform.png
│   └── validation.png
├── README.md
├── scripts/
│   ├── floci-down.sh
│   ├── floci-up.sh
│   └── validate.sh
└── terraform/
    ├── envs/
    │   ├── aws/
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── providers.tf
    │   │   └── variables.tf
    │   └── floci/
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── providers.tf
    └── modules/
        ├── compute/
        │   ├── alb.tf
        │   ├── asg.tf
        │   ├── ecr.tf
        │   ├── ecs.tf
        │   ├── iam.tf
        │   ├── outputs.tf
        │   ├── task.tf
        │   └── variables.tf
        ├── data/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        ├── frontend/
        │   ├── cloudfront.tf
        │   ├── outputs.tf
        │   ├── s3.tf
        │   └── variables.tf
        ├── monitoring/
        │   ├── main.tf
        │   ├── outputs.tf
        │   └── variables.tf
        └── network/
            ├── main.tf
            ├── outputs.tf
            └── variables.tf

## How to run

Prerequisites: Docker, Terraform, AWS CLI

```bash
./scripts/floci-up.sh      # start Floci and create all resources
./scripts/validate.sh      # check 16 resources
./scripts/floci-down.sh    # destroy everything and stop Floci
```

| Script | Purpose |
|---|---|
| `floci-up.sh` | Starts Floci, then runs `terraform apply` |
| `validate.sh` | Uses the AWS CLI to check that resources exist (PASS/FAIL) |
| `floci-down.sh` | Runs `terraform destroy` and stops Floci. If destroy fails, it resets Floci |

## Screenshots

#### Floci Page
![Floci](images/Floci.png)

#### Initialization Page
![Initialization](images/initialization.png)

#### Terraform Deploy Page
![Terraform](images/terraform.png)

#### Terraform Validation Page
![Validation](images/validation.png)

## Limitations

- The Virto app does not run on the emulated ECS (`desired_count = 0`, no image in ECR).
- CloudFront is created on Floci, but its domain does not serve traffic.
