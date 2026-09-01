output "vpe_ips" {
  description = "The endpoint gateway reserved ips"
  value       = module.vpes_consumer.vpe_ips
}

output "crn" {
  description = "The CRN of the endpoint gateway"
  value       = module.vpes_consumer.crn
}

output "vpe_ids" {
  description = "The map of endpoint gateway names to their IDs"
  value       = module.vpes_consumer.vpe_ids
}
