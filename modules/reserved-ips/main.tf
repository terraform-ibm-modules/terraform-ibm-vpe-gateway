##############################################################################
# VPE Locals
##############################################################################

locals {
  # List of IPs to create
  endpoint_ip_list = length(var.endpoint_ip_list) == 0 ? flatten([
    # Create object for each subnet
    for subnet in var.subnet_zone_list :
    concat([
      for service in var.reserved_ip_cloud_services :
      {
        ip_name   = "${subnet.name}-${service.service_name}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
        subnet_id = subnet.id
        name      = service.vpe_name != null ? "${service.vpe_name}-${replace(subnet.zone, "/${var.region}-/", "")}" : "${var.prefix}-${var.vpc_name}-${service.service_name}-${replace(subnet.zone, "/${var.region}-/", "")}"
      }
      ],
      [
        for service in var.cloud_service_by_crn :
        {
          ip_name   = service.vpe_name != null ? "${subnet.name}-${service.vpe_name}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip" : "${subnet.name}-${service.service_name != null ? service.service_name : element(split(":", service.crn), 4)}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
          subnet_id = subnet.id
          name      = service.vpe_name != null ? "${service.vpe_name}-${replace(subnet.zone, "/${var.region}-/", "")}" : "${var.prefix}-${var.vpc_name}-${service.service_name != null ? service.service_name : element(split(":", service.crn), 4)}-${replace(subnet.zone, "/${var.region}-/", "")}"
        }
    ])
  ]) : var.endpoint_ip_list

}

##############################################################################

##############################################################################
# Create Reserved IPs
##############################################################################

resource "ibm_is_subnet_reserved_ip" "ip" {
  for_each = {
    # Create a map based on endpoint IP name
    for gateway_ip in local.endpoint_ip_list :
    (gateway_ip.ip_name) => gateway_ip
    if lookup(var.reserved_ips, gateway_ip.name, null) == null
  }
  name   = each.value.name
  subnet = each.value.subnet_id

}
