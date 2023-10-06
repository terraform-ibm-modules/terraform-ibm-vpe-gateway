##############################################################################
# MAPPING OF AVAILABLE MULTI-TENANT VPE SERVICE ENDPOINTS
##############################################################################

locals {

  service_to_endpoint_map = {
    account-management         = "crn:v1:bluemix:public:account-management:global:::endpoint:${var.service_endpoints}.accounts.cloud.ibm.com"
    billing                    = "crn:v1:bluemix:public:billing:global:::endpoint:${var.service_endpoints}.billing.cloud.ibm.com"
    cloud-object-storage       = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
    codeengine                 = "crn:v1:bluemix:public:codeengine:${var.region}:::endpoint:${var.service_endpoints}.${var.region}.codeengine.cloud.ibm.com"
    container-registry         = "crn:v1:bluemix:public:container-registry:${contains(keys(local.container_registry_region_domain_map), var.region) ? var.region : "us-east"}:::endpoint:${lookup(local.container_registry_region_domain_map, var.region, "icr.io")}" # default to global if not in mapping
    context-based-restrictions = "crn:v1:bluemix:public:context-based-restrictions:global:::endpoint:${var.service_endpoints}.cbr.cloud.ibm.com"
    directlink                 = "crn:v1:bluemix:public:directlink:global:::endpoint:${var.service_endpoints}.directlink.cloud.ibm.com"
    dns-svcs                   = "crn:v1:bluemix:public:dns-svcs:global::::"
    enterprise                 = "crn:v1:bluemix:public:enterprise:global:::endpoint:${var.service_endpoints}.enterprise.cloud.ibm.com"
    global-search-tagging      = "crn:v1:bluemix:public:global-search-tagging:global:::endpoint:api.${var.service_endpoints}.global-search-tagging.cloud.ibm.com"
    globalcatalog              = "crn:v1:bluemix:public:globalcatalog:global:::endpoint:${var.service_endpoints}.globalcatalog.cloud.ibm.com"
    hs-crypto                  = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:api.${var.service_endpoints}.${var.region}.hs-crypto.cloud.ibm.com"
    hyperp-dbaas-mongodb       = "crn:v1:bluemix:public:hyperp-dbaas-mongodb:${var.region}:::endpoint:dbaas900-mongodb.${var.service_endpoints}.hyperp-dbaas.cloud.ibm.com"
    hyperp-dbaas-postgresql    = "crn:v1:bluemix:public:hyperp-dbaas-postgresql:${var.region}:::endpoint:dbaas900-postgresql.${var.service_endpoints}.hyperp-dbaas.cloud.ibm.com"
    iam-svcs                   = "crn:v1:bluemix:public:iam-svcs:global:::endpoint:${var.service_endpoints}.iam.cloud.ibm.com"
    is                         = "crn:v1:bluemix:public:is:${var.region}:::endpoint:${var.region}.${var.service_endpoints}.iaas.cloud.ibm.com"
    kms                        = "crn:v1:bluemix:public:kms:${var.region}:::endpoint:${var.service_endpoints}.${var.region}.kms.cloud.ibm.com"
    resource-controller        = "crn:v1:bluemix:public:resource-controller:global:::endpoint:${var.service_endpoints}.resource-controller.cloud.ibm.com"
    transit                    = "crn:v1:bluemix:public:transit:global:::endpoint:${var.service_endpoints}.transit.cloud.ibm.com"
    user-management            = "crn:v1:bluemix:public:user-management:global:::endpoint:${var.service_endpoints}.user-management.cloud.ibm.com"
    ntp                        = "ibm-ntp-server"
  }

  # CONTAINER-REGISTRY region-domain mappings
  # this cannot be pulled dynamically at this time, so hard-coding the region to registry domain mapping
  # Resource: https://cloud.ibm.com/docs/Registry?topic=Registry-registry_vpe&interface=ui#registry_vpe_endpoint_setup
  container_registry_region_domain_map = {
    "au-syd"   = "au.icr.io"  # ap-south
    "jp-osa"   = "jp2.icr.io" # jp-osa
    "jp-tok"   = "jp.icr.io"  # ap-north
    "eu-de"    = "de.icr.io"  # eu-central
    "eu-gb"    = "uk.icr.io"  # uk-south
    "ca-tor"   = "ca.icr.io"  # ca-tor
    "br-sao"   = "br.icr.io"  # br-sao
    "us-south" = "us.icr.io"  # us
  }

}
