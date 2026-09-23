variable "environment_name" {
  description = "Name of the environment (e.g. Dev, Prod) - used for tagging and naming"
  type        = string
}

variable "instance_size" {
  description = "EC2 instance type for this environment"
  type        = string
}

variable "ami_id" {
  description = "AMI ID (or SSM resolve string) for the EC2 instance"
  type        = string
  default     = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
