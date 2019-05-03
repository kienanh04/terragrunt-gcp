output "instance_groups" {
  value       = "${compact(concat(
                 google_compute_instance_group.group_01.*.self_link,
                 google_compute_instance_group.group_02.*.self_link,
                 list("")
                ))}" 
  description = "The URIs of the groups"
}

output "backend_services" {
  value       = "${module.lb-http.backend_services}"
  description = "The Backend Services of the loadbalancer"
}

output "external_ip" {
  value       = "${module.lb-http.external_ip}"
  description = "The external_ip  of the loadbalancer"
}
