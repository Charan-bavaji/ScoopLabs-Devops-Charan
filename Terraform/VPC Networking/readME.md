# Terraform: Public VPC Networking Foundation
 
## Problem Statement
Manually clicking through the AWS console to build networking (VPC, subnet, gateway, routing) is slow and error-prone. This project uses Terraform to automatically provision a public network foundation in AWS:
- A VPC (Virtual Private Cloud)
- A public Subnet inside that VPC
- An Internet Gateway (IGW) to allow traffic in/out
- A Route Table linking the subnet to the IGW, making the subnet public
## Files
- `variables.tf` — input variables: AWS region, VPC CIDR block, subnet CIDR block.
- `main.tf` — provider config + the 5 resources (VPC, Subnet, IGW, Route Table, Route Table Association).
- `outputs.tf` — prints the resulting resource IDs after apply.
## Resources Created (5 total)
1. `aws_vpc.main` — the VPC, tagged `Name = "Terraform-VPC"`.
2. `aws_subnet.public` — a subnet inside the VPC (`10.0.1.0/24` by default).
3. `aws_internet_gateway.gw` — attached to the VPC, the "door" to the internet.
4. `aws_route_table.public` — a route table on the VPC with a `0.0.0.0/0` route pointing at the IGW.
5. `aws_route_table_association.public` — links the subnet to the route table, which is what actually makes the subnet "public".
## Execution Steps
```bash
terraform init
terraform plan
# confirm: Plan: 5 to add, 0 to change, 0 to destroy.
 
terraform apply -auto-approve
# confirm: Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```
 
Then log into the AWS Console → VPC dashboard → check "Your VPCs" and "Subnets" to confirm `Terraform-VPC` and `Terraform-Public-Subnet` exist.
 
**Cleanup (important — avoid ongoing charges):**
```bash
terraform destroy -auto-approve
```
 
## Screenshots
