##############################################################################
# VPE Locals
##############################################################################

# NOTE: VPE Service Endpoint configuration can be found in service_endpoints.tf

locals {
  # List of Gateways to create
  gateway_list = concat([
    # Create object for each service
    for service in var.cloud_services :
    {
      name                         = service.vpe_name != null ? service.vpe_name : "${var.prefix}-${var.vpc_name}-${service.service_name}"
      service                      = service.service_name
      crn                          = local.service_to_endpoint_map[service.service_name]
      allow_dns_resolution_binding = service.allow_dns_resolution_binding
    }
    ],
    [
      for service in var.cloud_service_by_crn :
      {
        name                         = service.vpe_name != null ? service.vpe_name : "${var.prefix}-${var.vpc_name}-${service.service_name != null ? service.service_name : element(split(":", service.crn), 4)}" # service-name part of crn - see https://cloud.ibm.com/docs/account?topic=account-crn
        service                      = null
        crn                          = service.crn
        allow_dns_resolution_binding = service.allow_dns_resolution_binding
      }
    ]
  )

  # List of IPs to create
  endpoint_ip_list = flatten([
    # Create object for each subnet
    for subnet in var.subnet_zone_list :
    concat([
      for service in var.cloud_services :
      {
        ip_name      = "${subnet.name}-${service.service_name}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
        subnet_id    = subnet.id
        gateway_name = service.vpe_name != null ? service.vpe_name : "${var.prefix}-${var.vpc_name}-${service.service_name}"
        name         = service.vpe_name != null ? "${service.vpe_name}-${subnet.name}-${replace(subnet.zone, "/${var.region}-/", "")}" : "${var.prefix}-${var.vpc_name}-${subnet.name}-${service.service_name}-${replace(subnet.zone, "/${var.region}-/", "")}"
      }
      ],
      [
        for service in var.cloud_service_by_crn :
        {
          ip_name      = service.vpe_name != null ? "${subnet.name}-${service.vpe_name}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip" : "${subnet.name}-${service.service_name != null ? service.service_name : element(split(":", service.crn), 4)}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
          subnet_id    = subnet.id
          gateway_name = service.vpe_name != null ? service.vpe_name : "${var.prefix}-${var.vpc_name}-${service.service_name != null ? service.service_name : element(split(":", service.crn), 4)}"
          name         = service.vpe_name != null ? "${service.vpe_name}-${replace(subnet.zone, "/${var.region}-/", "")}" : "${var.prefix}-${var.vpc_name}-${service.service_name != null ? service.service_name : element(split(":", service.crn), 4)}-${replace(subnet.zone, "/${var.region}-/", "")}"
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

module "ip" {
  source           = "./modules/reserved-ips"
  endpoint_ip_list = local.endpoint_ip_list
  reserved_ips     = var.reserved_ips
  prefix           = var.prefix
  vpc_name         = var.vpc_name
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
    resource_type = length(regexall("crn:v1:([^:]*:){6}", each.value.crn)) > 0 ? strcontains(each.value.crn, "private-path-service-gateway") ? "private_path_service_gateway" : "provider_cloud_service" : "provider_infrastructure_service"
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
  reserved_ip = lookup(var.reserved_ips, each.value.name, module.ip.reserved_ip_map[each.value.name])
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
