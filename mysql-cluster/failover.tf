resource "google_sql_database_instance" "failover-replica" {
  count                 = "${var.failover_replica ? 1 : 0}"
  project               = "${var.project_id}"
  name                  = "${local.name}-failover"
  database_version      = "${var.database_version}"
  region                = "${var.region}"
  master_instance_name  = "${google_sql_database_instance.default.name}"
  replica_configuration = ["${merge(var.failover_replica_configuration, map("failover_target", true))}"]

  settings {
    tier                        = "${var.failover_replica_tier}"
    activation_policy           = "${var.failover_replica_activation_policy}"
    authorized_gae_applications = ["${var.authorized_gae_applications}"]
    ip_configuration            = {
      ipv4_enabled     = "false"
      private_network  = "${data.terraform_remote_state.vpc.self_link}"
    }

    crash_safe_replication = "${var.failover_replica_crash_safe_replication}"
    disk_autoresize        = "${var.failover_replica_disk_autoresize}"
    disk_size              = "${var.failover_replica_disk_size}"
    disk_type              = "${var.failover_replica_disk_type}"
    pricing_plan           = "${var.failover_replica_pricing_plan}"
    replication_type       = "${var.failover_replica_replication_type}"
    user_labels            = "${var.failover_replica_user_labels}"
    database_flags         = ["${var.failover_replica_database_flags}"]

    location_preference {
      zone = "${var.region}-${var.failover_replica_zone}"
    }

    maintenance_window {
      day          = "${var.failover_replica_maintenance_window_day}"
      hour         = "${var.failover_replica_maintenance_window_hour}"
      update_track = "${var.failover_replica_maintenance_window_update_track}"
    }
  }

  depends_on = ["google_sql_database_instance.default"]

  lifecycle {
    ignore_changes = ["disk_size"]
  }
}
