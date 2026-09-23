output "adopted_vpe_ips" {
  description = "Reserved IPs managed by the adopted VPE module for all provided subnets"
  value       = module.adopt_vpe.vpe_ips
}

output "adopted_crn" {
  description = "CRN of adopted gateway"
  value       = module.adopt_vpe.crn
}
