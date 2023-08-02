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
    concat([
      for service in var.cloud_services :
      {
        ip_name      = "${subnet.name}-${service}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
        subnet_id    = subnet.id
        gateway_name = "${var.prefix}-${var.vpc_name}-${service}"
      }
      ],
      [
        for service in var.cloud_service_by_crn :
        {
          ip_name      = "${subnet.name}-${service.name}-gateway-${replace(subnet.zone, "/${var.region}-/", "")}-ip"
          subnet_id    = subnet.id
          gateway_name = "${var.prefix}-${var.vpc_name}-${service.name}"
        }
    ])
  ])

  # Convert the virtual_endpoint_gateway output from list to a map
  vpe_map = {
    for gateway in ibm_is_virtual_endpoint_gateway.vpe :
    (gateway.name) => gateway
  }

  # Map of Services to endpoints
  service_to_endpoint_map = {
    account-management          = "crn:v1:bluemix:public:account-management:global:::endpoint:${var.service_endpoints}.accounts.cloud.ibm.com"
    billing                     = "crn:v1:bluemix:public:billing:global:::endpoint:${var.service_endpoints}.billing.cloud.ibm.com"
    cloud-object-storage        = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
    codeengine                  = "crn:v1:bluemix:public:codeengine:${var.region}:::endpoint:${var.service_endpoints}.${var.region}.codeengine.cloud.ibm.com"
    container-registry          = "crn:v1:bluemix:public:container-registry:${var.region}:::endpoint:vpe.${var.region}.container-registry.cloud.ibm.com"
    databases-for-cassandra     = "crn:v1:bluemix:public:databases-for-cassandra:${var.region}:::endpoint:${var.service_endpoints}.databases-for-cassandra.cloud.ibm.com"
    databases-for-elasticsearch = "crn:v1:bluemix:public:databases-for-elasticsearch:${var.region}:::endpoint:${var.service_endpoints}.databases-for-elasticsearch.cloud.ibm.com"
    databases-for-enterprisedb  = "crn:v1:bluemix:public:databases-for-enterprisedb:${var.region}:::${var.service_endpoints}.databases-for-enterprisedb.cloud.ibm.com"
    databases-for-mongodb       = "crn:v1:bluemix:public:databases-for-mongodb:${var.region}:::endpoint:${var.service_endpoints}.databases-for-mongodb.cloud.ibm.com"
    databases-for-postgresql    = "crn:v1:bluemix:public:databases-for-postgresql:${var.region}:::endpoint:${var.service_endpoints}.databases-for-postgresql.cloud.ibm.com"
    databases-for-redis         = "crn:v1:bluemix:public:databases-for-redis:${var.region}:::endpoint:${var.service_endpoints}.databases-for-redis.cloud.ibm.com"
    directlink                  = "crn:v1:bluemix:public:directlink:global:::endpoint:${var.service_endpoints}.directlink.cloud.ibm.com"
    dns-svcs                    = "crn:v1:bluemix:public:dns-svcs:global::::"
    enterprise                  = "crn:v1:bluemix:public:enterprise:global:::endpoint:${var.service_endpoints}.enterprise.cloud.ibm.com"
    global-search-tagging       = "crn:v1:bluemix:public:global-search-tagging:global:::endpoint:api.${var.service_endpoints}.global-search-tagging.cloud.ibm.com"
    globalcatalog               = "crn:v1:bluemix:public:globalcatalog:global:::endpoint:${var.service_endpoints}.globalcatalog.cloud.ibm.com"
    hs-crypto                   = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:api.${var.service_endpoints}.${var.region}.hs-crypto.cloud.ibm.com"
    hyperp-dbaas-mongodb        = "crn:v1:bluemix:public:hyperp-dbaas-mongodb:${var.region}:::endpoint:dbaas900-mongodb.${var.service_endpoints}.hyperp-dbaas.cloud.ibm.com"
    hyperp-dbaas-postgresql     = "crn:v1:bluemix:public:hyperp-dbaas-postgresql:${var.region}:::endpoint:dbaas900-postgresql.${var.service_endpoints}.hyperp-dbaas.cloud.ibm.com"
    iam-identity                = "crn:v1:bluemix:public:iam-identity:global:::endpoint:${var.service_endpoints}.iam.cloud.ibm.com"
    iam-svcs                    = "crn:v1:bluemix:public:iam-svcs:global:::endpoint:${var.service_endpoints}.iam.cloud.ibm.com"
    is                          = "crn:v1:bluemix:public:is:${var.region}:::endpoint:${var.region}.${var.service_endpoints}.iaas.cloud.ibm.com"
    kms                         = "crn:v1:bluemix:public:kms:${var.region}:::endpoint:${var.service_endpoints}.${var.region}.kms.cloud.ibm.com"
    resource-controller         = "crn:v1:bluemix:public:resource-controller:global:::endpoint:${var.service_endpoints}.resource-controller.cloud.ibm.com"
    secrets-manager             = "crn:v1:bluemix:public:secrets-manager:${var.region}:::endpoint:${var.service_endpoints}.secrets-manager.cloud.ibm.com"
    transit                     = "crn:v1:bluemix:public:transit:global:::endpoint:${var.service_endpoints}.transit.cloud.ibm.com"
    user-management             = "crn:v1:bluemix:public:user-management:global:::endpoint:${var.service_endpoints}.user-management.cloud.ibm.com"
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
  count           = length(local.gateway_list)
  name            = "${var.prefix}-${local.gateway_list[count.index].name}"
  vpc             = var.vpc_id
  resource_group  = var.resource_group_id
  security_groups = var.security_group_ids
  target {
    crn           = local.gateway_list[count.index].service == null ? local.gateway_list[count.index].crn : local.service_to_endpoint_map[local.gateway_list[count.index].service]
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
  gateway     = local.vpe_map[each.value.gateway_name].id
  reserved_ip = ibm_is_subnet_reserved_ip.ip[each.key].reserved_ip
}

##############################################################################
