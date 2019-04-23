// Master
output "instance_name" {
  value       = "${module.mysql-cluster.instance_name}"
  description = "The instance name for the master instance"
}

output "instance_ip_address" {
  value       = "${module.mysql-cluster.instance_ip_address}"
  description = "The IPv4 address assigned for the master instance"
}

output "instance_first_ip_address" {
  value       = "${module.mysql-cluster.instance_first_ip_address}"
  description = "The first IPv4 address of the addresses assigned for the master instance."
}

output "instance_connection_name" {
  value       = "${module.mysql-cluster.instance_connection_name}"
  description = "The connection name of the master instance to be used in connection strings"
}

output "instance_self_link" {
  value       = "${module.mysql-cluster.instance_self_link}"
  description = "The URI of the master instance"
}

// Replicas
output "replicas_instance_first_ip_addresses" {
  value       = ["${module.mysql-cluster.replicas_instance_first_ip_addresses}"]
  description = "The first IPv4 addresses of the addresses assigned for the replica instances"
}

output "replicas_instance_connection_names" {
  value       = ["${module.mysql-cluster.replicas_instance_connection_names}"]
  description = "The connection names of the replica instances to be used in connection strings"
}

output "replicas_instance_self_links" {
  value       = ["${module.mysql-cluster.replicas_instance_self_links}"]
  description = "The URIs of the replica instances"
}

output "read_replica_instance_names" {
  value       = "${module.mysql-cluster.read_replica_instance_names}"
  description = "The instance names for the read replica instances"
}

// Failover Replicas
output "failover-replica_instance_first_ip_address" {
  value       = "${module.mysql-cluster.failover-replica_instance_first_ip_address}"
  description = "The first IPv4 address of the addesses assigned for the failover-replica instance"
}

output "failover-replica_instance_connection_name" {
  value       = "${module.mysql-cluster.failover-replica_instance_connection_name}"
  description = "The connection name of the failover-replica instance to be used in connection strings"
}

output "failover-replica_instance_self_link" {
  value       = "${module.mysql-cluster.failover-replica_instance_self_link}"
  description = "The URI of the failover-replica instance"
}

output "failover-replica_instance_name" {
  value       = "${module.mysql-cluster.failover-replica_instance_name}"
  description = "The instance name for the failover replica instance"
}
