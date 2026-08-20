##############################################################################
# VPE Locals
##############################################################################

# NOTE: VPE Service Endpoint configuration can be found in service_endpoints.tf

locals {
  # ---------------------------------------------------------------------------
  # Helpers for deriving a gateway name from a cloud_service_by_crn entry
  # ---------------------------------------------------------------------------
  crn_svc_name = { # map: crn -> derived service-name segment
    for service in var.cloud_service_by_crn :
    service.crn => (service.service_name != null ? service.service_name : element(split(":", service.crn), 4))
  }

  crn_gw_name = { # map: crn -> computed gateway name
    for service in var.cloud_service_by_crn :
    service.crn => (service.vpe_name != null ? service.vpe_name : "${var.prefix}-${var.vpc_name}-${local.crn_svc_name[service.crn]}")
  }

  # ---------------------------------------------------------------------------
  # Gateways that should be CREATED by this module (no existing_vpe_id)
  # ---------------------------------------------------------------------------
  gateway_list_create = concat(
    [
      for service in var.cloud_services :
      {
        name                        = service.vpe_name != null ? service.vpe_name : "${var.prefix}-${var.vpc_name}-${service.service_name}"
        service                     = service.service_name
        crn                         = local.service_to_endpoint_map[service.service_name]
        dns_resolution_binding_mode = service.dns_resolution_binding_mode
      }
    ],
    [
      for service in var.cloud_service_by_crn :
      {
        name                        = local.crn_gw_name[service.crn]
        service                     = null
        crn                         = service.crn
        dns_resolution_binding_mode = service.dns_resolution_binding_mode
      }
      if service.existing_vpe_id == null
    ]
  )

  # ---------------------------------------------------------------------------
  # Gateways that already exist (existing_vpe_id is provided) — not created by this module
  # ---------------------------------------------------------------------------
  gateway_list_existing = [
    for service in var.cloud_service_by_crn :
    {
      name = local.crn_gw_name[service.crn]
    }
    if service.existing_vpe_id != null
  ]

  # ---------------------------------------------------------------------------
  # Full endpoint-IP list (unchanged logic — covers both new and existing gateways)
  # ---------------------------------------------------------------------------
  endpoint_ip_list = flatten([
    for subnet in var.subnet_zone_list :
    concat(
      [
        for service in var.cloud_services :
        {
          ip_name      = "${subnet.name}-${service.service_name}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
          subnet_id    = subnet.id
          gateway_name = service.vpe_name != null ? service.vpe_name : "${var.prefix}-${var.vpc_name}-${service.service_name}"
          name         = service.vpe_name != null ? "${service.vpe_name}-${replace(subnet.zone, "/${var.region}-/", "")}" : "${var.prefix}-${var.vpc_name}-${service.service_name}-${replace(subnet.zone, "/${var.region}-/", "")}"
        }
      ],
      [
        for service in var.cloud_service_by_crn :
        {
          ip_name      = "${subnet.name}-${local.crn_svc_name[service.crn]}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
          subnet_id    = subnet.id
          gateway_name = local.crn_gw_name[service.crn]
          name         = service.vpe_name != null ? "${service.vpe_name}-${replace(subnet.zone, "/${var.region}-/", "")}" : "${var.prefix}-${var.vpc_name}-${local.crn_svc_name[service.crn]}-${replace(subnet.zone, "/${var.region}-/", "")}"
        }
      ]
    )
  ])

  # ---------------------------------------------------------------------------
  # Unified vpe_map: merges created resources + existing data sources
  # ---------------------------------------------------------------------------
  vpe_map = merge(
    # Gateways created by this module
    {
      for gateway in ibm_is_virtual_endpoint_gateway.vpe :
      (gateway.name) => gateway
    },
    # Pre-existing gateways resolved via data source
    {
      for entry in local.gateway_list_existing :
      (entry.name) => data.ibm_is_virtual_endpoint_gateway.vpe_existing[entry.name]
    }
  )
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
# Create Endpoint Gateways (only for entries without existing_vpe_id)
##############################################################################

resource "ibm_is_virtual_endpoint_gateway" "vpe" {
  for_each = {
    for gateway in local.gateway_list_create :
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
  dns_resolution_binding_mode = each.value.dns_resolution_binding_mode
}

##############################################################################

##############################################################################
# Look up pre-existing Endpoint Gateways by name
##############################################################################

data "ibm_is_virtual_endpoint_gateway" "vpe_existing" {
  for_each = {
    for entry in local.gateway_list_existing :
    (entry.name) => entry
  }
  name = each.key
}

##############################################################################

##############################################################################
# Attach Endpoint Gateways to Reserved IPs
##############################################################################

resource "ibm_is_virtual_endpoint_gateway_ip" "endpoint_gateway_ip" {
  for_each = {
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

# Reload pre-existing gateways after IP attachment so vpe_ips output reflects all bound IPs
data "ibm_is_virtual_endpoint_gateway" "vpe_existing_reload" {
  depends_on = [ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip]
  for_each = {
    for entry in local.gateway_list_existing :
    (entry.name) => entry
  }
  name = each.key
}
