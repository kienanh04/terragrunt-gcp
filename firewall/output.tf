output "self_link" { 
  value       = "${google_compute_firewall.this.self_link}" 
  description = "The URI of the created firewall" 
}
