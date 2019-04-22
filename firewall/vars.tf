variable "name" { default = "firewall" }
variable "priority" { default = "1000" }
variable "protocol" { default = "tcp" }
variable "ports" { default = ["22","80","443"] }
variable "source_tags" { default = [] }
variable "source_ranges" { default = [] }
variable "target_tags" { default = [] }

variable "project_id" {}
variable "project_env" { default = "Production" }
variable "project_env_short" { default = "prd" }
variable "region" { default = "us-west1" }
variable "terraform_remote_state_bucket" { default = "" }
variable "terraform_remote_state_region" { default = "" }
variable "terraform_remote_state_profile" { default = "" }
variable "terraform_remote_state_arn" { default = "" }
variable "terraform_remote_state_key" { default = "" }
