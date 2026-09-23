output "dev_public_ip" {
  description = "Public IP of the Dev web server"
  value       = module.dev_server.public_ip
}

output "prod_public_ip" {
  description = "Public IP of the Prod web server"
  value       = module.prod_server.public_ip
}
