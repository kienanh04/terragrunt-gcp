provider "google" {
  project     = "${var.project_id}"
  region      = "${var.region}"
}

terraform {
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    encrypt        = true
    bucket         = "${var.terraform_remote_state_bucket}"
    key            = "${var.terraform_remote_state_key}"
    region         = "${var.terraform_remote_state_region}"
    profile        = "${var.terraform_remote_state_profile}"
    role_arn       = "${var.terraform_remote_state_arn}"
  }
}

resource "google_compute_firewall" "this" {
  name     = "${var.name}"
  network  = "${data.terraform_remote_state.vpc.name}"
  priority = "${var.priority}"

  allow {
    protocol = "${var.protocol}"
    ports    = ["${var.ports}"]
  }

  source_ranges = ["${var.source_ranges}"]
  source_tags   = ["${var.source_tags}"]
  target_tags   = ["${var.target_tags}"]
}
