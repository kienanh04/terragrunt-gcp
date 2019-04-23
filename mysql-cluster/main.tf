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

locals {
  ip_configuration = [{
    ipv4_enabled    = "false"
    private_network = "${data.terraform_remote_state.vpc.subnets_self_links["${var.subnet_num}"]}"
  }]

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
    enabled = true
    start_time = "${var.backup_start_time}"
  }
}

module "mysql-cluster" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version = "1.1.1"

  name             = "${var.name}"
  database_version = "${var.database_version}"
  project_id       = "${var.project_id}"
  zone             = "${var.zone}"

  ## DB setting:
  user_name                       = "${var.user_name}"
  user_password                   = "${var.user_password}"
  user_host                       = "${var.user_host}"
  db_name                         = "${var.db_name}"
  db_charset                      = "${var.db_charset}"
  db_collation                    = "${var.db_collation}"
  authorized_gae_applications     = ["${var.authorized_gae_applications}"]

  ## Primary instance:
  tier                            = "${var.tier}"
  pricing_plan                    = "${var.pricing_plan}"
  disk_size                       = "${var.disk_size}"
  disk_type                       = "${var.disk_type}"
  database_flags                  = ["${local.database_flags}"]
  activation_policy               = "${var.activation_policy}"
  ip_configuration                = "${local.ip_configuration}"
  backup_configuration            = "${local.backup_configuration}"
  maintenance_window_day          = "${var.maintenance_window_day}"
  maintenance_window_hour         = "${var.maintenance_window_hour}"
  maintenance_window_update_track = "${var.maintenance_window_update_track}"
  
  ## Read Replicas:
  read_replica_size                            = "${var.read_replica_size}"
  read_replica_tier                            = "${var.read_replica_tier}"
  read_replica_pricing_plan                    = "${var.read_replica_pricing_plan}"
  read_replica_replication_type                = "${var.read_replica_replication_type}"
  read_replica_disk_size                       = "${var.read_replica_disk_size}"
  read_replica_disk_type                       = "${var.read_replica_disk_type}"
  read_replica_database_flags                  = ["${local.database_flags}"]
  read_replica_configuration                   = "${var.read_replica_configuration}"
  read_replica_activation_policy               = "${var.read_replica_activation_policy}"
  read_replica_ip_configuration                = "${local.ip_configuration}"
  read_replica_maintenance_window_day          = "${var.read_replica_maintenance_window_day}"
  read_replica_maintenance_window_hour         = "${var.read_replica_maintenance_window_hour}"
  read_replica_maintenance_window_update_track = "${var.read_replica_maintenance_window_update_track}"

  ## Failover Replica:
  failover_replica                                 = "${var.failover_replica}"
  failover_replica_pricing_plan                    = "${var.failover_replica_pricing_plan}"
  failover_replica_replication_type                = "${var.failover_replica_replication_type}"
  failover_replica_tier                            = "${var.failover_replica_tier}"
  failover_replica_zone                            = "${var.failover_replica_zone}"
  failover_replica_activation_policy               = "${var.activation_policy}"
  failover_replica_configuration                   = "${var.failover_replica_configuration}"
  failover_replica_disk_size                       = "${var.failover_replica_disk_size}"
  failover_replica_disk_type                       = "${var.failover_replica_disk_type}"
  failover_replica_ip_configuration                = "${local.ip_configuration}"
  failover_replica_maintenance_window_day          = "${var.maintenance_window_day}"
  failover_replica_maintenance_window_hour         = "${var.maintenance_window_hour}"
  failover_replica_maintenance_window_update_track = "${var.maintenance_window_update_track}"
  
}
