output "ids" {
  value       = "${module.gce.ids}" 
  description = "The IDs of the instance"
}

output "self_links" {
  value       = "${module.gce.self_links}" 
  description = "The URIs of the instance"
}

output "private_ips" {
  value       = "${module.gce.private_ips }" 
  description = "The internal IPs of the instance"
}

output "public_ips" {
  value       = "${module.gce.public_ips }" 
  description = "The given external IPs or the ephemeral IPs"
}
