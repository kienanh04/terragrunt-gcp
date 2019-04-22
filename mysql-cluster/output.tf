// Master
output "instance_name" {
  value       = "${google_sql_database_instance.default.name}"
  description = "The instance name for the master instance"
}

output "instance_ip_address" {
  value       = "${google_sql_database_instance.default.ip_address}"
  description = "The IPv4 address assigned for the master instance"
}

output "instance_first_ip_address" {
  value       = "${google_sql_database_instance.default.first_ip_address}"
  description = "The first IPv4 address of the addresses assigned for the master instance."
}

output "instance_connection_name" {
  value       = "${google_sql_database_instance.default.connection_name}"
  description = "The connection name of the master instance to be used in connection strings"
}

output "instance_self_link" {
  value       = "${google_sql_database_instance.default.self_link}"
  description = "The URI of the master instance"
}

// Replicas
output "replicas_instance_first_ip_addresses" {
  value       = ["${google_sql_database_instance.replicas.*.ip_address}"]
  description = "The first IPv4 addresses of the addresses assigned for the replica instances"
}

output "replicas_instance_connection_names" {
  value       = ["${google_sql_database_instance.replicas.*.connection_name}"]
  description = "The connection names of the replica instances to be used in connection strings"
}

output "replicas_instance_self_links" {
  value       = ["${google_sql_database_instance.replicas.*.self_link}"]
  description = "The URIs of the replica instances"
}

output "read_replica_instance_names" {
  value       = "${google_sql_database_instance.replicas.*.name}"
  description = "The instance names for the read replica instances"
}

// Failover Replicas
output "failover-replica_instance_first_ip_address" {
  value       = "${google_sql_database_instance.failover-replica.*.ip_address}"
  description = "The first IPv4 address of the addesses assigned for the failover-replica instance"
}

output "failover-replica_instance_connection_name" {
  value       = "${google_sql_database_instance.failover-replica.*.connection_name}"
  description = "The connection name of the failover-replica instance to be used in connection strings"
}

output "failover-replica_instance_self_link" {
  value       = "${google_sql_database_instance.failover-replica.*.self_link}"
  description = "The URI of the failover-replica instance"
}

output "failover-replica_instance_name" {
  value       = "${google_sql_database_instance.failover-replica.*.name}"
  description = "The instance name for the failover replica instance"
}
