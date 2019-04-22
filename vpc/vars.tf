variable "project_name" {}
variable "project_id" {}
variable "project_env" { default = "Production" }
variable "project_env_short" { default = "prd" }

variable "region" { default = "us-west1" }
variable "vpc_cidr" {}
variable "routing_mode" { default = "GLOBAL" }

variable "dns_private" { default = true }
variable "dns_public" { default = true }
variable "domain_name" { default = "example.com" }
variable "domain_local" { default = "example.internal" }
