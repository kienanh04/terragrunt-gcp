output "name" {
  value       = "${module.vpc.network_name}"
  description = "The name of the VPC being created"
}

output "subnets_names" {
  value       = "${module.vpc.subnets_names}"
  description = "The names of the subnets being created"
}

output "subnets_ips" {
  value       = "${module.vpc.subnets_ips}"
  description = "The IPs and CIDRs of the subnets being created"
}

output "routes" {
  value       = "${module.vpc.routes}"
  description = "The routes associated with this VPC"
}

output "subnets_self_links" {
  value       = "${module.vpc.subnets_self_links}"
  description = "The self-links of subnets being created"
}

output "dns_private_name" {
  value       = "${element(google_dns_managed_zone.private.*.name,0)}"
  description = "The name of private dns zone"
}

output "dns_public_name" {
  value       = "${element(google_dns_managed_zone.public.*.name,0)}"
  description = "The name of public dns zone"
}

output "domain_local" {
  value       = "${var.domain_local}"
  description = "The private domain name"
}

output "domain_name" {
  value       = "${var.domain_name}"
  description = "The public domain name"
}
