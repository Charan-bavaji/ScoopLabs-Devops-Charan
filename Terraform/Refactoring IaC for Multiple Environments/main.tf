provider "aws" {
  region = "us-east-1"
}

module "dev_server" {
  source = "./modules/web_server"

  environment_name = "Dev"
  instance_size    = "t2.micro"
}

module "prod_server" {
  source = "./modules/web_server"

  environment_name = "Prod"
  instance_size    = "t2.large"
}
