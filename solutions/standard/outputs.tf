output "vpe_ips" {
  description = "The endpoint gateway reserved ips"
  value       = module.vpe.vpe_ips
}

output "crn" {
  description = "The CRN of the endpoint gateway"
  value       = module.vpe.crn
}
