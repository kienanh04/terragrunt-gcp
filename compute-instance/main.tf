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

module "gce" {
  source       = "github.com/thanhbn87/terraform-gcp.git//compute-instance"

  project_id   = "${var.project_id}"
  region       = "${var.region}"
  num_of_zones = "${var.num_of_zones}"

  name               = "${var.name}"
  instance_count     = "${var.instance_count}"
  static_external_ip = "${var.static_external_ip}"
  subnetwork         = "${data.terraform_remote_state.vpc.subnets_self_links["${var.subnet_num}"]}"
  instance_type      = "${var.instance_type}"
  tags               = ["${var.tags}"]
  image              = "${var.image}"
  image_family       = "${var.image_family}"
  image_project      = "${var.image_project}"
  disk_size          = "${var.disk_size}"
  ssh_pub_file       = "${var.ssh_pub_file}"
  ssh_user           = "${var.ssh_user}"
}
