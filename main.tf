##############################################################################
# VPE Locals
##############################################################################

# NOTE: VPE Service Endpoint configuration can be found in service_endpoints.tf

locals {
  # List of Gateways to create
  gateway_list = concat([
    # Create object for each service
    for target_service_name, vpe_details in var.cloud_services :
    {
      name                         = vpe_details.vpe_name != null ? vpe_details.vpe_name : "${var.prefix}-${var.vpc_name}-${target_service_name}"
      service                      = target_service_name
      crn                          = local.service_to_endpoint_map[target_service_name]
      allow_dns_resolution_binding = vpe_details.allow_dns_resolution_binding
    }
    ],
    [
      for target_crn, vpe_details in var.cloud_service_by_crn :
      {
        name                         = vpe_details.vpe_name != null ? vpe_details.vpe_name : "${var.prefix}-${var.vpc_name}-${vpe_details.service_name != null ? vpe_details.service_name : element(split(":", target_crn), 4)}" # service-name part of crn - see https://cloud.ibm.com/docs/account?topic=account-crn
        service                      = null
        crn                          = target_crn
        allow_dns_resolution_binding = vpe_details.allow_dns_resolution_binding
      }
    ]
  )

  # List of IPs to create
  endpoint_ip_list = flatten([
    # Create object for each subnet
    for subnet in var.subnet_zone_list :
    concat([
      for target_service_name, vpe_details in var.cloud_services :
      {
        ip_name      = "${subnet.name}-${target_service_name}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
        subnet_id    = subnet.id
        gateway_name = vpe_details.vpe_name != null ? vpe_details.vpe_name : "${var.prefix}-${var.vpc_name}-${target_service_name}" # lookup(vpe_details, "name", "${var.prefix}-${var.vpc_name}-${target_service_name}")
      }
      ],
      [
        for target_crn, vpe_details in var.cloud_service_by_crn :
        {
          ip_name      = vpe_details.vpe_name != null ? "${subnet.name}-${vpe_details.vpe_name}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip" : "${subnet.name}-${vpe_details.service_name != null ? vpe_details.service_name : element(split(":", target_crn), 4)}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
          subnet_id    = subnet.id
          gateway_name = vpe_details.vpe_name != null ? vpe_details.vpe_name : "${var.prefix}-${var.vpc_name}-${vpe_details.service_name != null ? vpe_details.service_name : element(split(":", target_crn), 4)}"
        }
    ])
  ])

  # Convert the virtual_endpoint_gateway output from list to a map
  vpe_map = {
    for gateway in ibm_is_virtual_endpoint_gateway.vpe :
    (gateway.name) => gateway
  }

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
  }
  subnet = each.value.subnet_id
}

##############################################################################

##############################################################################
# Create Endpoint Gateways
##############################################################################

resource "ibm_is_virtual_endpoint_gateway" "vpe" {
  for_each = { # Create a map based on gateway name
    for gateway in local.gateway_list :
    (gateway.name) => gateway
  }
  name            = each.key
  vpc             = var.vpc_id
  resource_group  = var.resource_group_id
  security_groups = var.security_group_ids

  # check if target is a CRN and handle accordingly
  target {
    name          = length(regexall("crn:v1:([^:]*:){6}", each.value.crn)) > 0 ? null : each.value.crn
    crn           = length(regexall("crn:v1:([^:]*:){6}", each.value.crn)) > 0 ? each.value.crn : null
    resource_type = length(regexall("crn:v1:([^:]*:){6}", each.value.crn)) > 0 ? "provider_cloud_service" : "provider_infrastructure_service"
  }
  allow_dns_resolution_binding = each.value.allow_dns_resolution_binding
}

##############################################################################

##############################################################################
# Attach Endpoint Gateways to Reserved IPs
##############################################################################

resource "ibm_is_virtual_endpoint_gateway_ip" "endpoint_gateway_ip" {
  for_each = {
    # Create a map based on endpoint IP
    for gateway_ip in local.endpoint_ip_list :
    (gateway_ip.ip_name) => gateway_ip
  }
  gateway     = local.vpe_map[each.value.gateway_name].id
  reserved_ip = ibm_is_subnet_reserved_ip.ip[each.key].reserved_ip
}

##############################################################################

##############################################################################
# Datasource to load endpoint gateways details once resources are fully created
##############################################################################

data "ibm_is_virtual_endpoint_gateway" "vpe" {
  depends_on = [ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip]
  for_each   = ibm_is_virtual_endpoint_gateway.vpe
  name       = each.key
}
