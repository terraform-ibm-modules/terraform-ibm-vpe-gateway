output "vpe_ips" {
  description = "The endpoint gateway reserved ips. For adopted gateways (existing_vpe_id set), only the reserved IPs created by this module invocation are returned."
  value = merge(
    { for vpe_pg in data.ibm_is_virtual_endpoint_gateway.vpe :
      # Sorting the array by ids to ensure stability across idempotent plan/apply
    vpe_pg.name => flatten([for id in sort([for ip in vpe_pg.ips : ip.id]) : [for ip in vpe_pg.ips : ip if ip.id == id]]) },
    { for vpe_pg in data.ibm_is_virtual_endpoint_gateway.vpe_existing :
      # Filter to only IPs created by this module invocation, identified via the reserved_ip_map from the ip submodule.
      # This prevents pre-existing IPs on a shared gateway from leaking into this module's output.
      # Sorting by ID mirrors the newly-created gateway path to ensure stability across plan/apply.
    vpe_pg.name => flatten([for id in sort([for ip in vpe_pg.ips : ip.id if contains(values(module.ip.reserved_ip_map), ip.id)]) : [for ip in vpe_pg.ips : ip if ip.id == id]]) }
  )
}

output "crn" {
  description = "The CRN of the endpoint gateway"
  value = concat(
    [for vpe_crn in ibm_is_virtual_endpoint_gateway.vpe : vpe_crn.crn],
    [for vpe_crn in data.ibm_is_virtual_endpoint_gateway.vpe_existing : vpe_crn.crn]
  )
}

output "gateway_ids" {
  description = "Map of gateway name to gateway ID for all created endpoint gateways"
  value       = { for gw in ibm_is_virtual_endpoint_gateway.vpe : gw.name => gw.id }
}
