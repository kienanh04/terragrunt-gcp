locals {
  primary_zone       = "${var.zone}"
  read_replica_zones = ["${compact(split(",", var.read_replica_zones))}"]

  zone_mapping = {
    enabled  = ["${local.read_replica_zones}"]
    disabled = "${list(local.primary_zone)}"
  }

  zones_enabled = "${length(local.read_replica_zones) > 0}"
  mod_by        = "${local.zones_enabled ? length(local.read_replica_zones) : 1}"

  zones = "${local.zone_mapping["${local.zones_enabled ? "enabled" : "disabled"}"]}"

}

resource "google_sql_database_instance" "replicas" {
  count                 = "${var.read_replica_size}"
  project               = "${var.project_id}"
  name                  = "${local.name}-replica${count.index}"
  database_version      = "${var.database_version}"
  region                = "${var.region}"
  master_instance_name  = "${google_sql_database_instance.default.name}"
  replica_configuration = ["${merge(var.read_replica_configuration, map("failover_target", false))}"]

  settings {
    tier                        = "${var.read_replica_tier}"
    activation_policy           = "${var.read_replica_activation_policy}"
    ip_configuration            = {
      ipv4_enabled     = "false"
      private_network  = "${data.terraform_remote_state.vpc.self_link}"
    }
    authorized_gae_applications = ["${var.authorized_gae_applications}"]

    crash_safe_replication = "${var.read_replica_crash_safe_replication}"
    disk_autoresize        = "${var.read_replica_disk_autoresize}"
    disk_size              = "${var.read_replica_disk_size}"
    disk_type              = "${var.read_replica_disk_type}"
    pricing_plan           = "${var.read_replica_pricing_plan}"
    replication_type       = "${var.read_replica_replication_type}"
    user_labels            = "${var.read_replica_user_labels}"
    database_flags         = ["${concat(var.read_replica_database_flags,local.database_flags)}"]

    location_preference {
      zone = "${length(local.zones) == 0 ? "" : "${var.region}-${local.zones[count.index % local.mod_by]}"}"
    }

    maintenance_window {
      day          = "${var.read_replica_maintenance_window_day}"
      hour         = "${var.read_replica_maintenance_window_hour}"
      update_track = "${var.read_replica_maintenance_window_update_track}"
    }
  }

  depends_on = ["google_sql_database_instance.default"]

  lifecycle {
    ignore_changes = ["disk_size"]
  }
}
