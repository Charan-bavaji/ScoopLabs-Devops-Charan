# Terraform Assignment: Making IaC Reusable

## Concept Task: variables.tf vs terraform.tfvars

**`variables.tf`**
- This is where you **declare** variables — their name, type, description, and (optionally) a default value.
- It defines *what* inputs your configuration accepts. It does not set the actual values you want to use for a specific run.

**`terraform.tfvars`**
- This is where you **assign actual values** to the variables declared in `variables.tf`.
- Terraform loads this file automatically (no flag needed) and fills in the variables with these values.
- Lets you change values (like region, AMI, or instance size) without touching the main code — useful for different environments (dev/staging/prod) or keeping sensitive values separate from the logic.

**In short:** `variables.tf` defines the "slots" your code can accept, `terraform.tfvars` fills those slots with real values. Same code, different inputs.

## Hands-on Task: Refactored Code Using Variables

**variables.tf**
```hcl
variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID (or SSM resolve string) for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

**main.tf**
```hcl
provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

**terraform.tfvars**
```hcl
aws_region    = "us-east-1"
ami_id        = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
instance_type = "t2.micro"
```

**Proving dynamic injection:** `ami_id` has no default, so Terraform pulls it only from `terraform.tfvars` (or a `-var` flag, or a prompt if missing). Running `terraform plan` shows the resolved values for `region`, `ami`, and `instance_type` coming from the tfvars file rather than being hardcoded in `main.tf`. Changing a value in `terraform.tfvars` (e.g. `instance_type = "t3.micro"`) and re-running `terraform plan` immediately reflects the new value in the plan output — proving the injection is dynamic.

## Submission Requirements
- `variables.tf` and `main.tf`: included above.
