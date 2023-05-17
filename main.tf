##############################################################################
# VPE Locals
##############################################################################

locals {
  # List of Gateways to create
  gateway_list = concat([
    # Create object for each service
    for service in var.cloud_services :
    {
      name    = "${var.vpc_name}-${service}"
      service = service
      crn     = null
    }
    ],
    [
      for service in var.cloud_service_by_crn :
      {
        name    = "${var.vpc_name}-${service.name}"
        service = null
        crn     = service.crn
      }
    ]
  )

  # List of IPs to create
  endpoint_ip_list = flatten([
    # Create object for each subnet
    for subnet in var.subnet_zone_list :
    [
      for service in var.cloud_services :
      {
        ip_name      = "${subnet.name}-${service}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
        subnet_id    = subnet.id
        gateway_name = "${var.vpc_name}-${service}"
      }
    ]
  ])

  # Map of Services to endpoints
  service_to_endpoint_map = {
    kms                     = "crn:v1:bluemix:public:kms:${var.region}:::endpoint:${var.service_endpoints}.${var.region}.kms.cloud.ibm.com"
    hs-crypto               = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:api.${var.service_endpoints}.${var.region}.hs-crypto.cloud.ibm.com"
    cloud-object-storage    = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
    container-registry      = "crn:v1:bluemix:public:container-registry:${var.region}:::endpoint:vpe.${var.region}.container-registry.cloud.ibm.com"
    account-management      = "crn:v1:bluemix:public:account-management:global:::endpoint:${var.service_endpoints}.accounts.cloud.ibm.com"
    billing                 = "crn:v1:bluemix:public:billing:global:::endpoint:${var.service_endpoints}.billing.cloud.ibm.com"
    codeengine              = "crn:v1:bluemix:public:codeengine:${var.region}:::endpoint:${var.service_endpoints}.${var.region}.codeengine.cloud.ibm.com"
    directlink              = "crn:v1:bluemix:public:directlink:global:::endpoint:${var.service_endpoints}.directlink.cloud.ibm.com"
    dns-svcs                = "crn:v1:bluemix:public:dns-svcs:global::::"
    enterprise              = "crn:v1:bluemix:public:enterprise:global:::endpoint:${var.service_endpoints}.enterprise.cloud.ibm.com"
    globalcatalog           = "crn:v1:bluemix:public:globalcatalog:global:::endpoint:${var.service_endpoints}.globalcatalog.cloud.ibm.com"
    global-search-tagging   = "crn:v1:bluemix:public:global-search-tagging:global:::endpoint:api.${var.service_endpoints}.global-search-tagging.cloud.ibm.com"
    hyperp-dbaas-mongodb    = "crn:v1:bluemix:public:hyperp-dbaas-mongodb:${var.region}:::endpoint:dbaas900-mongodb.${var.service_endpoints}.hyperp-dbaas.cloud.ibm.com"
    hyperp-dbaas-postgresql = "crn:v1:bluemix:public:hyperp-dbaas-postgresql:${var.region}:::endpoint:dbaas900-postgresql.${var.service_endpoints}.hyperp-dbaas.cloud.ibm.com"
    iam-svcs                = "crn:v1:bluemix:public:iam-svcs:global:::endpoint:${var.service_endpoints}.iam.cloud.ibm.com"
    resource-controller     = "crn:v1:bluemix:public:resource-controller:global:::endpoint:${var.service_endpoints}.resource-controller.cloud.ibm.com"
    transit                 = "crn:v1:bluemix:public:transit:global:::endpoint:${var.service_endpoints}.transit.cloud.ibm.com"
    user-management         = "crn:v1:bluemix:public:user-management:global:::endpoint:${var.service_endpoints}.user-management.cloud.ibm.com"
    is                      = "crn:v1:bluemix:public:is:${var.region}:::endpoint:${var.region}.${var.service_endpoints}.iaas.cloud.ibm.com"
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
  for_each = {
    # Create map based on gateway name if enabled
    for gateway in local.gateway_list :
    (gateway.name) => gateway
  }

  name            = "${var.prefix}-${each.key}"
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
    for gateway_ip in local.endpoint_ip_list :
    (gateway_ip.ip_name) => gateway_ip
  }
  gateway     = ibm_is_virtual_endpoint_gateway.vpe[each.value.gateway_name].id
  reserved_ip = ibm_is_subnet_reserved_ip.ip[each.key].reserved_ip
}

##############################################################################
