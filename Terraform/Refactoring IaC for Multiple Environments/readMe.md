# Terraform Modules: Refactoring IaC for Multiple Environments
 
## Problem Statement
A 300-line `main.tf` provisions a single web server. The business now needs Dev, QA, and Prod versions of that same server. Copy-pasting the file three times breaks the DRY principle and becomes a maintenance nightmare — a fix or security change would need to be repeated in every copy. This project refactors the raw code into a reusable **Terraform module** that is called once per environment with different inputs.
 
## Directory Structure
```
terraform-environments/
├── main.tf                     # Root config - calls the module twice (Dev, Prod)
├── outputs.tf                  # Root outputs - IPs of both servers
└── modules/
    └── web_server/
        ├── main.tf              # Reusable EC2 + Security Group logic
        ├── variables.tf         # environment_name, instance_size, ami_id
        └── outputs.tf           # instance_id, public_ip, security_group_id
```
 
## How the Module Works
- `modules/web_server` contains the generic, parameterized infrastructure: one `aws_instance` and one `aws_security_group` (allowing HTTP/SSH in, all traffic out).
- Nothing inside the module is hardcoded for a specific environment — `environment_name` and `instance_size` are passed in as variables and used for naming/tagging and sizing.
- The root `main.tf` calls this same module twice:
  - `module "dev_server"` → `environment_name = "Dev"`, `instance_size = "t2.micro"`
  - `module "prod_server"` → `environment_name = "Prod"`, `instance_size = "t2.large"`
- Both environments run through the exact same logic, so any future change (e.g. a new ingress rule) is made once in the module and automatically applies to Dev, QA, and Prod alike.
## Execution Steps
```bash
terraform init
# Initializing modules... - modules.web_server gets initialized here
 
terraform plan
# Plan should show resources for BOTH module.dev_server and module.prod_server
# (2x aws_instance, 2x aws_security_group)
```
 
**Screenshot to capture:** the directory tree (e.g. `tree terraform-environments` or your file explorer) showing the isolated `modules/web_server` structure.
 
Run `terraform apply -auto-approve` if you want to actually provision both, then `terraform destroy -auto-approve` afterward to avoid ongoing charges — Prod's `t2.large` in particular is not free-tier eligible.
 
## Why Modular IaC? (Benefits)
- **Reusability:** The same server logic is written once and reused for Dev, QA, Prod, or any future environment, instead of being copy-pasted and drifting out of sync.
- **Standardizing security policies:** The security group rules live in one place. Tightening SSH access, for example, is a single change that automatically applies everywhere the module is used.
- **Reducing blast radius:** Environments are isolated behind clear inputs (`environment_name`, `instance_size`). A mistake in a variable passed to `dev_server` cannot accidentally reconfigure `prod_server` — the module boundary limits how far a change or an error can spread.
## Submission Checklist
<img width="1918" height="968" alt="image" src="https://github.com/user-attachments/assets/ae135288-6a60-49b6-bd39-ee59a5b0c38a" />
<img width="952" height="930" alt="image" src="https://github.com/user-attachments/assets/8466a107-c4d7-48f8-9d82-876cc3744d22" />
