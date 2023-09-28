##############################################################################
# VPE Locals
##############################################################################

locals {
  # List of Gateways to create
  gateway_list = concat([
    # Create object for each service
    for service in var.cloud_services :
    {
      name    = lookup(var.vpe_names, service, "${var.prefix}-${var.vpc_name}-${service}")
      service = service
      crn     = null
    }
    ],
    [
      for service in var.cloud_service_by_crn :
      {
        name    = lookup(var.vpe_names, service.name, "${var.prefix}-${var.vpc_name}-${service.name}")
        service = null
        crn     = service.crn
      }
    ]
  )

  # Convert the virtual_endpoint_gateway output from list to a map
  vpe_map = {
    for gateway in ibm_is_virtual_endpoint_gateway.vpe :
    (gateway.name) => gateway
  }

  # Map of Services to endpoints
  service_to_endpoint_map = {
    account-management      = "crn:v1:bluemix:public:account-management:global:::endpoint:${var.service_endpoints}.accounts.cloud.ibm.com"
    billing                 = "crn:v1:bluemix:public:billing:global:::endpoint:${var.service_endpoints}.billing.cloud.ibm.com"
    cloud-object-storage    = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
    codeengine              = "crn:v1:bluemix:public:codeengine:${var.region}:::endpoint:${var.service_endpoints}.${var.region}.codeengine.cloud.ibm.com"
    container-registry      = "crn:v1:bluemix:public:container-registry:${var.region}:::endpoint:${var.region}.icr.io"
    directlink              = "crn:v1:bluemix:public:directlink:global:::endpoint:${var.service_endpoints}.directlink.cloud.ibm.com"
    dns-svcs                = "crn:v1:bluemix:public:dns-svcs:global::::"
    enterprise              = "crn:v1:bluemix:public:enterprise:global:::endpoint:${var.service_endpoints}.enterprise.cloud.ibm.com"
    global-search-tagging   = "crn:v1:bluemix:public:global-search-tagging:global:::endpoint:api.${var.service_endpoints}.global-search-tagging.cloud.ibm.com"
    globalcatalog           = "crn:v1:bluemix:public:globalcatalog:global:::endpoint:${var.service_endpoints}.globalcatalog.cloud.ibm.com"
    hs-crypto               = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:api.${var.service_endpoints}.${var.region}.hs-crypto.cloud.ibm.com"
    hyperp-dbaas-mongodb    = "crn:v1:bluemix:public:hyperp-dbaas-mongodb:${var.region}:::endpoint:dbaas900-mongodb.${var.service_endpoints}.hyperp-dbaas.cloud.ibm.com"
    hyperp-dbaas-postgresql = "crn:v1:bluemix:public:hyperp-dbaas-postgresql:${var.region}:::endpoint:dbaas900-postgresql.${var.service_endpoints}.hyperp-dbaas.cloud.ibm.com"
    iam-svcs                = "crn:v1:bluemix:public:iam-svcs:global:::endpoint:${var.service_endpoints}.iam.cloud.ibm.com"
    is                      = "crn:v1:bluemix:public:is:${var.region}:::endpoint:${var.region}.${var.service_endpoints}.iaas.cloud.ibm.com"
    kms                     = "crn:v1:bluemix:public:kms:${var.region}:::endpoint:${var.service_endpoints}.${var.region}.kms.cloud.ibm.com"
    resource-controller     = "crn:v1:bluemix:public:resource-controller:global:::endpoint:${var.service_endpoints}.resource-controller.cloud.ibm.com"
    transit                 = "crn:v1:bluemix:public:transit:global:::endpoint:${var.service_endpoints}.transit.cloud.ibm.com"
    user-management         = "crn:v1:bluemix:public:user-management:global:::endpoint:${var.service_endpoints}.user-management.cloud.ibm.com"
  }
}

##############################################################################

##############################################################################
# Create Reserved IPs
##############################################################################

module "create_reserved_ips" {
  source               = "./modules/reserved-ips"
  prefix               = var.prefix
  vpc_name             = var.vpc_name
  subnet_zone_list     = var.subnet_zone_list
  vpe_names            = var.vpe_names
  cloud_services       = var.cloud_services
  cloud_service_by_crn = var.cloud_service_by_crn
  reserved_ips         = var.reserved_ips
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
  target {
    crn           = each.value.service == null ? each.value.crn : local.service_to_endpoint_map[each.value.service]
    resource_type = "provider_cloud_service"
  }
}

##############################################################################

##############################################################################
# Attach Endpoint Gateways to Reserved IPs
##############################################################################

resource "ibm_is_virtual_endpoint_gateway_ip" "endpoint_gateway_ip" {
  for_each = {
    # Create a map based on endpoint IP
    for gateway_ip in module.create_reserved_ips.endpoint_ip_list :
    (gateway_ip.ip_name) => gateway_ip
  }
  gateway     = local.vpe_map[each.value.gateway_name].id
  reserved_ip = var.reserved_ips == null ? module.create_reserved_ips.reserved_ips[each.key].reserved_ip : var.reserved_ips[each.value.ip_name].reserved_ip
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

##############################################################################
