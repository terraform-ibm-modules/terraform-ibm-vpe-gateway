output "vpe_ips" {
  description = "The endpoint gateway reserved ips"
  value = merge(
    { for vpe_pg in data.ibm_is_virtual_endpoint_gateway.vpe :
      # Sorting the array by ids to ensure stability across idempotent plan/apply
    vpe_pg.name => flatten([for id in sort([for ip in vpe_pg.ips : ip.id]) : [for ip in vpe_pg.ips : ip if ip.id == id]]) },
    { for vpe_pg in data.ibm_is_virtual_endpoint_gateway.vpe_existing :
    vpe_pg.name => flatten([for id in sort([for ip in vpe_pg.ips : ip.id]) : [for ip in vpe_pg.ips : ip if ip.id == id]]) }
  )
}

output "crn" {
  description = "The CRN of the endpoint gateway"
  value = concat(
    [for vpe_crn in ibm_is_virtual_endpoint_gateway.vpe : vpe_crn.crn],
    [for vpe_crn in data.ibm_is_virtual_endpoint_gateway.vpe_existing : vpe_crn.crn]
  )
}
