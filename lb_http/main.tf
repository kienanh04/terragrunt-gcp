provider "google" {
  project     = "${var.project_id}"
  region      = "${var.region}"
}

terraform {
  backend "s3" {}
}

data "google_compute_zones" "available" {}

data "terraform_remote_state" "gce" {
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

data "null_data_source" "instance_lists_01" {
  count  = "${length(data.terraform_remote_state.gce.self_links)}"
  inputs = {
    self_links = "${ "${floor(count.index % 2)}" == 0 ? "${element("${data.terraform_remote_state.gce.self_links}",count.index)}" : "" }"
  }
}

data "null_data_source" "instance_lists_02" {
  count  = "${length(data.terraform_remote_state.gce.self_links)}"
  inputs = {
    self_links = "${ "${floor(count.index % 2)}" == 1 ? "${element("${data.terraform_remote_state.gce.self_links}",count.index)}" : "" }"
  }
}

resource "google_compute_instance_group" "group_01" {
  count       = "${length(compact(concat(data.null_data_source.instance_lists_01.*.inputs.self_links))) > 0 ? 1 : 0}"
  name        = "${var.name}-01"
  description = "${var.desc} group 01"

  instances = ["${compact(concat(data.null_data_source.instance_lists_01.*.inputs.self_links))}"]

  named_port {
    name = "http"
    port = "${var.http_port}"
  }

  named_port {
    name = "https"
    port = "${var.https_port}"
  }

  zone = "${data.google_compute_zones.available.names[0]}"
}

resource "google_compute_instance_group" "group_02" {
  count       = "${length(compact(concat(data.null_data_source.instance_lists_02.*.inputs.self_links))) > 0 ? 1 : 0}"
  name        = "${var.name}-02"
  description = "${var.desc} group 02"

  instances = ["${compact(concat(data.null_data_source.instance_lists_02.*.inputs.self_links))}"]

  named_port {
    name = "http"
    port = "${var.http_port}"
  }

  named_port {
    name = "https"
    port = "${var.https_port}"
  }

  zone = "${data.google_compute_zones.available.names[1]}"
}

data "null_data_source" "backends" {
  count   = "${length(data.terraform_remote_state.gce.self_links)}"
  inputs {
    group = "${element(
                 "${compact(concat(
                   google_compute_instance_group.group_01.*.self_link,
                   google_compute_instance_group.group_02.*.self_link,
                   list("")
                 ))}",
                 count.index
            )}"
  }
}

module "lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "1.0.10"
  name              = "${var.name}-lb"
  target_tags       = ["${var.target_tags}"]
  firewall_networks = ["${var.firewall_networks}"]
  backends          = {
    "0" = "${data.null_data_source.backends.*.inputs}"
  }
  backend_params    = [
    # health check path, port name, port number, timeout seconds.
    "${var.http_check_path},${var.http_port_name},${var.http_port},10"
  ]
}
