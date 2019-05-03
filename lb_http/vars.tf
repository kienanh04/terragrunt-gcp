variable "project_id" {}
variable "region" { default = "us-west1" }

variable "terraform_remote_state_bucket" { default = "" }
variable "terraform_remote_state_key" { default = "" }
variable "terraform_remote_state_region" { default = "" }
variable "terraform_remote_state_profile" { default = "" }
variable "terraform_remote_state_arn" { default = "" }

variable "name" { default = "LB for Unmanaged instance group" }
variable "desc" { default = "Load Balancer for The group of unmanaged instances" }
variable "http_port" { default = "80" }
variable "http_port_name" { default = "http" }
variable "http_check_path" { default = "/" }
variable "https_port" { default = "443" }
variable "https_port_name" { default = "https" }

variable "target_tags" { default = ["web"] }
variable "firewall_networks" { default = ["default"] }
