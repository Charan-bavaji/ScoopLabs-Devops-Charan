# Terraform Assignment: Provisioning Cloud Resources

## Concept Task: `terraform plan` vs `terraform apply`

**`terraform plan`**
- A **dry run**. Terraform compares your `.tf` code against the current state file (and the real infrastructure) and shows what it *would* do — create, update, or destroy — without actually making any changes.
- Used to review and verify changes before committing to them. Nothing in AWS/Azure is touched.

**`terraform apply`**
- **Executes** the plan. Terraform makes the real API calls to create/update/destroy resources in your cloud account, then updates the state file to match the new reality.
- By default it shows the same plan output first and asks for a `yes` confirmation before making changes (unless run with `-auto-approve`).

**In short:** `plan` = preview (safe, read-only), `apply` = provision (makes real changes, costs money/resources).

## Hands-on Task: Provision a Free-Tier EC2 Instance

The `aws_instance` resource uses the SSM parameter to resolve the correct Amazon Linux 2023 AMI for whatever region is set, avoiding the "AMI ID doesn't exist in this region" mismatch that comes with hardcoding an AMI ID, and uses the free-tier-eligible `t2.micro` type:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t2.micro"
}
```

**Steps run:**
```bash
terraform init
terraform plan    # reviewed the planned creation of 1 aws_instance
terraform apply   # confirmed with 'yes', instance provisioned
```

## Submission Requirements
- `.tf` code: included above (also in `main.tf`).
<img width="1919" height="559" alt="Screenshot 2026-09-17 095318" src="https://github.com/user-attachments/assets/06b832b1-92c3-4df5-8300-50d87b4efee8" />

