provider "google-beta" {
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

locals {
  database_flags = [
    {
      name  = "default_time_zone"
      value = "${var.time_zone}"
    },
    { 
      name  = "slow_query_log"
      value = "on"
    },
    { 
      name  = "log_output"
      value = "FILE"
    },
  ]

  backup_configuration = {
    binary_log_enabled = true
    enabled            = true
    start_time         = "${var.backup_start_time}"
  }

}

resource "google_compute_global_address" "cloud_sql" {
  provider      = "google-beta"
  name          = "${var.cloud_sql_ip_name}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "${var.cloud_sql_ip}"
  prefix_length = "${var.cloud_sql_prefix}"
  network       = "${data.terraform_remote_state.vpc.self_link}"
}

resource "google_service_networking_connection" "private_connect" {
  provider      = "google-beta"
  network       = "${data.terraform_remote_state.vpc.self_link}"
  service       = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.cloud_sql.name}"]
}

resource "google_sql_database_instance" "default" {
  provider         = "google-beta"
  project          = "${var.project_id}"
  name             = "${var.name == "" ? "${lower(var.project_name)}-${lower(var.project_env_short)}" : "${var.name}" }"
  database_version = "${var.database_version}"
  region           = "${var.region}"
  depends_on       = ["google_service_networking_connection.private_connect"]

  settings {
    tier                        = "${var.tier}"
    activation_policy           = "${var.activation_policy}"
    authorized_gae_applications = ["${var.authorized_gae_applications}"]
    backup_configuration        = ["${local.backup_configuration}"]
    ip_configuration            = {
      ipv4_enabled     = "false"
      private_network  = "${data.terraform_remote_state.vpc.self_link}"
    } 

    disk_autoresize = "${var.disk_autoresize}"

    disk_size      = "${var.disk_size}"
    disk_type      = "${var.disk_type}"
    pricing_plan   = "${var.pricing_plan}"
    user_labels    = "${var.user_labels}"
    database_flags = ["${concat(var.database_flags,local.database_flags)}"]

    location_preference {
      zone = "${var.region}-${var.zone}"
    }

    maintenance_window {
      day          = "${var.maintenance_window_day}"
      hour         = "${var.maintenance_window_hour}"
      update_track = "${var.maintenance_window_update_track}"
    }
  }

  lifecycle {
    ignore_changes = ["disk_size"]
  }

  timeouts {
    create = "${var.create_timeout}"
    update = "${var.update_timeout}"
    delete = "${var.delete_timeout}"
  }
}

resource "google_sql_database" "default" {
  name       = "${var.db_name == "default" ? "${lower(var.project_name)}_${lower(var.project_env_short)}" : "${var.db_name}"}"
  project    = "${var.project_id}"
  instance   = "${google_sql_database_instance.default.name}"
  charset    = "${var.db_charset}"
  collation  = "${var.db_collation}"
  depends_on = ["google_sql_database_instance.default"]
}

resource "google_sql_database" "additional_databases" {
  count      = "${length(var.additional_databases)}"
  project    = "${var.project_id}"
  name       = "${lookup(var.additional_databases[count.index], "name")}"
  charset    = "${lookup(var.additional_databases[count.index], "charset", "")}"
  collation  = "${lookup(var.additional_databases[count.index], "collation", "")}"
  instance   = "${google_sql_database_instance.default.name}"
  depends_on = ["google_sql_database_instance.default"]
}

resource "random_id" "user-password" {
  keepers = {
    name = "${google_sql_database_instance.default.name}"
  }

  byte_length = 8
  depends_on  = ["google_sql_database_instance.default"]
}

resource "google_sql_user" "default" {
  name       = "${var.user_name == "default" ? "${lower(var.project_env_short)}_usr" : "${var.user_name}"}"
  project    = "${var.project_id}"
  instance   = "${google_sql_database_instance.default.name}"
  host       = "${var.user_host}"
  password   = "${var.user_password == "" ? random_id.user-password.hex : var.user_password}"
  depends_on = ["google_sql_database_instance.default"]
}

resource "google_sql_user" "additional_users" {
  count      = "${length(var.additional_users)}"
  project    = "${var.project_id}"
  name       = "${lookup(var.additional_users[count.index], "name")}"
  password   = "${lookup(var.additional_users[count.index], "password", random_id.user-password.hex)}"
  host       = "${lookup(var.additional_users[count.index], "host", var.user_host)}"
  instance   = "${google_sql_database_instance.default.name}"
  depends_on = ["google_sql_database_instance.default"]
}
