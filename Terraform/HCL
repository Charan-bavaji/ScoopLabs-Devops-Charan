# Terraform Assignment: HCL Syntax & Provider Setup

## Concept Task: Structure of a Terraform Block

Terraform configuration files are written in HashiCorp Configuration Language (HCL). Every block in HCL follows the same basic structure:

```
<BLOCK TYPE> "<LABEL 1>" "<LABEL 2>" {
  # Body
  <ARGUMENT> = <VALUE>
}
```

**1. Block Type**
Tells Terraform what kind of object this block defines. Common types include `provider`, `resource`, `variable`, `output`, and `module`. In the code below, `provider` and `resource` are the block types.

**2. Labels**
Labels identify the block. The number of labels depends on the block type:
- A `provider` block takes **one label** — the provider name (e.g. `"aws"`).
- A `resource` block takes **two labels** — the resource type (e.g. `"aws_instance"`) and a local name Terraform uses to refer to that resource elsewhere in the config (e.g. `"example"`).

**3. Body**
The body sits inside the `{ }` and holds arguments (key–value pairs) that configure the block — for example `region = "us-east-1"` or `instance_type = "t3.micro"`. Some blocks can also contain nested blocks inside their body.

## Hands-on Task: AWS Provider in main.tf

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = "t3.micro"
}
```

**Breakdown:**
- `provider "aws"` — Block Type: `provider`, Label: `"aws"`. Body sets `region = "us-east-1"`, telling Terraform which AWS region to create resources in.
- `resource "aws_instance" "example"` — Block Type: `resource`, Labels: `"aws_instance"` (resource type) and `"example"` (local name). Body specifies the `ami` (using an SSM parameter to always resolve the latest Amazon Linux 2023 AMI) and `instance_type` (`t3.micro`).
