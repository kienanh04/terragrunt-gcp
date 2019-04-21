provider "google" {
  project     = "${var.project_id}"
  region      = "${var.region}"
}

terraform {
  backend "s3" {}
}

locals {
  network_name = "${lower(var.project_name)}-${lower(var.project_env)}"
}

data "google_compute_zones" "available" {}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "0.6.0"
  project_id   = "${var.project_id}"
  network_name = "${local.network_name}"
  routing_mode = "${var.routing_mode}"

  subnets = [
    {
      subnet_name   = "${local.network_name}-public"
      subnet_ip     = "${cidrsubnet("${var.vpc_cidr}", 2, 0)}"
      subnet_region = "${var.region}"
    },
    {
      subnet_name           = "${local.network_name}-private"
      subnet_ip             = "${cidrsubnet("${var.vpc_cidr}", 2, 1)}"
      subnet_region         = "${var.region}"
      subnet_private_access = "true"
    },
    {
      subnet_name           = "${local.network_name}-database"
      subnet_ip             = "${cidrsubnet("${var.vpc_cidr}", 2, 2)}"
      subnet_region         = "${var.region}"
      subnet_private_access = "true"
    },
  ]

  secondary_ranges = {
    "${local.network_name}-public" = []
    "${local.network_name}-private" = []
    "${local.network_name}-database" = []
  }
}
