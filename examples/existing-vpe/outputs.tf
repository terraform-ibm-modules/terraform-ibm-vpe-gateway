output "vpe_ips" {
  description = "Reserved IPs managed by this module call"
  value       = module.vpe_consumer.vpe_ips
}

output "crn" {
  description = "CRN of the existing endpoint gateway"
  value       = module.vpe_consumer.crn
}
