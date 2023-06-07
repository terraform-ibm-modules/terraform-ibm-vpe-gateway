output "vpe_ips" {
  description = "The endpoint gateway reserved ips"
  value       = [for vpe_pg in ibm_is_virtual_endpoint_gateway.vpe : vpe_pg.ips]
}

output "crn" {
  description = "The CRN of the endpoint gateway"
  value       = [for vpe_crn in ibm_is_virtual_endpoint_gateway.vpe : vpe_crn.crn]
}
