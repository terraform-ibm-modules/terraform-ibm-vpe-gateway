output "owner_vpe_ips" {
  description = "Reserved IPs managed by the owner module call"
  value       = module.vpe_owner.vpe_ips
}

output "consumer_vpe_ips" {
  description = "Reserved IPs managed by the consumer (adopter) module call"
  value       = module.vpe_consumer.vpe_ips
}

output "owner_crn" {
  description = "CRN of the endpoint gateway created by the owner"
  value       = module.vpe_owner.crn
}

output "consumer_crn" {
  description = "CRN of the adopted endpoint gateway as seen from the consumer"
  value       = module.vpe_consumer.crn
}
