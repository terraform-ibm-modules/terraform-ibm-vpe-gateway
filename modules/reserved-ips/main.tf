##############################################################################
# VPE Locals
##############################################################################

locals {

  # List of IPs to create
  endpoint_ip_list = flatten([
    # Create object for each subnet
    for subnet in var.subnet_zone_list :
    concat([
      for service in var.cloud_services :
      {
        ip_name      = "${subnet.name}-${service}-gw-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
        subnet_id    = subnet.id
        gateway_name = lookup(var.vpe_names, service, "${var.prefix}-${var.vpc_name}-${service}")
      }
      ],
      [
        for service in var.cloud_service_by_crn :
        {
          ip_name      = "${subnet.name}-${service.name}-gw-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
          subnet_id    = subnet.id
          gateway_name = lookup(var.vpe_names, service.name, "${var.prefix}-${var.vpc_name}-${service.name}")
        }
    ])
  ])
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
    if var.reserved_ips == null
  }
  subnet = each.value.subnet_id
  name   = each.value.ip_name
}

##############################################################################
