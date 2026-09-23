output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the created public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the created Internet Gateway"
  value       = aws_internet_gateway.gw.id
}

output "route_table_id" {
  description = "ID of the created public route table"
  value       = aws_route_table.public.id
}
