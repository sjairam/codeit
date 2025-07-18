# Configure AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change this to your desired AWS region
}

# Data sources to retrieve secrets from AWS Secrets Manager
data "aws_secretsmanager_secret" "dev_harvard_lts_rke_rancher" {
  name = "dev_harvard_lts_rke_rancher"
}

data "aws_secretsmanager_secret" "dev-ssl-key" {
  name = "dev-ssl-key"
}

data "aws_secretsmanager_secret" "dev_harvard_lts_rke_argocd" {
  name = "dev_harvard_lts_rke_argocd"
}

# Retrieve the actual secret values
data "aws_secretsmanager_secret_version" "secret_a_version" {
  secret_id = data.aws_secretsmanager_secret.dev_harvard_lts_rke_rancher.id
}

data "aws_secretsmanager_secret_version" "secret_b_version" {
  secret_id = data.aws_secretsmanager_secret.dev-ssl-key.id
}

data "aws_secretsmanager_secret_version" "secret_c_version" {
  secret_id = data.aws_secretsmanager_secret.dev_harvard_lts_rke_argocd.id
}

# Output the secret values (be careful with this in production)
output "secret_a_value" {
  description = "this is secret :"
  value       = data.aws_secretsmanager_secret_version.secret_a_version.secret_string
}

output "secret_b_value" {
  description = "this is secret :"
  value       = data.aws_secretsmanager_secret_version.secret_b_version.secret_string
  sensitive   = true
}

output "secret_c_value" {
  description = "this is secret :"
  value       = data.aws_secretsmanager_secret_version.secret_c_version.secret_string
  sensitive   = true
}

# Output secret ARNs (non-sensitive)
output "secret_a_arn" {
  value = data.aws_secretsmanager_secret.dev_harvard_lts_rke_rancher.arn
}

output "secret_b_arn" {
  value = data.aws_secretsmanager_secret.dev-ssl-key.arn
}

output "secret_c_arn" {
  value = data.aws_secretsmanager_secret.dev_harvard_lts_rke_argocd.arn
}
