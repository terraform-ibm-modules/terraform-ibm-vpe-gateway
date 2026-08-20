output "vpe_ips" {
  description = "The endpoint gateway reserved ips"
  value = merge(
    # IPs for gateways created by this module (reloaded after IP attachment)
    {
      for vpe_pg in data.ibm_is_virtual_endpoint_gateway.vpe :
      # Sorting the array by ids to ensure stability across idempotent plan/apply
      vpe_pg.name => flatten([for id in sort([for ip in vpe_pg.ips : ip.id]) : [for ip in vpe_pg.ips : ip if ip.id == id]])
    },
    # IPs for pre-existing gateways (reloaded after IP attachment)
    {
      for vpe_pg in data.ibm_is_virtual_endpoint_gateway.vpe_existing_reload :
      vpe_pg.name => flatten([for id in sort([for ip in vpe_pg.ips : ip.id]) : [for ip in vpe_pg.ips : ip if ip.id == id]])
    }
  )
}

output "crn" {
  description = "The CRN of the endpoint gateway"
  value = concat(
    [for vpe_crn in ibm_is_virtual_endpoint_gateway.vpe : vpe_crn.crn],
    [for vpe_crn in data.ibm_is_virtual_endpoint_gateway.vpe_existing : vpe_crn.crn]
  )
}
