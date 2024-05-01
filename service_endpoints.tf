##############################################################################
# MAPPING OF AVAILABLE MULTI-TENANT VPE SERVICE ENDPOINTS
##############################################################################

locals {

  endpoint_prefix = var.service_endpoints == "private" ? "private." : ""

  service_to_endpoint_map = {
    account-management          = "crn:v1:bluemix:public:account-management:global:::endpoint:${local.endpoint_prefix}accounts.cloud.ibm.com"
    billing                     = "crn:v1:bluemix:public:billing:global:::endpoint:${local.endpoint_prefix}billing.cloud.ibm.com"
    cloud-object-storage        = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
    cloud-object-storage-config = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:config.direct.cloud-object-storage.cloud.ibm.com"
    codeengine                  = "crn:v1:bluemix:public:codeengine:${var.region}:::endpoint:${local.endpoint_prefix}${var.region}.codeengine.cloud.ibm.com"
    container-registry          = "crn:v1:bluemix:public:container-registry:${contains(keys(local.container_registry_region_domain_map), var.region) ? var.region : "us-east"}:::endpoint:${lookup(local.container_registry_region_domain_map, var.region, "icr.io")}" # default to global if not in mapping
    containers-kubernetes       = "crn:v1:bluemix:public:containers-kubernetes:${var.region}:::endpoint:api.${var.region}.containers.cloud.ibm.com"
    context-based-restrictions  = "crn:v1:bluemix:public:context-based-restrictions:global:::endpoint:${local.endpoint_prefix}cbr.cloud.ibm.com"
    directlink                  = "crn:v1:bluemix:public:directlink:global:::endpoint:${local.endpoint_prefix}directlink.cloud.ibm.com"
    dns-svcs                    = "crn:v1:bluemix:public:dns-svcs:global::::"
    enterprise                  = "crn:v1:bluemix:public:enterprise:global:::endpoint:${local.endpoint_prefix}enterprise.cloud.ibm.com"
    global-search-tagging       = "crn:v1:bluemix:public:global-search-tagging:global:::endpoint:api.${local.endpoint_prefix}global-search-tagging.cloud.ibm.com"
    globalcatalog               = "crn:v1:bluemix:public:globalcatalog:global:::endpoint:${local.endpoint_prefix}globalcatalog.cloud.ibm.com"
    hs-crypto                   = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:api.${local.endpoint_prefix}${var.region}.hs-crypto.cloud.ibm.com"
    hs-crypto-cert-mgr          = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:cert-mgr.${local.endpoint_prefix}${var.region}.hs-crypto.cloud.ibm.com"
    hs-crypto-ep11              = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:ep11.${local.endpoint_prefix}${var.region}.hs-crypto.cloud.ibm.com"
    hs-crypto-ep11-az1          = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:ep11-az1.${local.endpoint_prefix}${var.region}.hs-crypto.cloud.ibm.com"
    hs-crypto-ep11-az2          = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:ep11-az2.${local.endpoint_prefix}${var.region}.hs-crypto.cloud.ibm.com"
    hs-crypto-ep11-az3          = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:ep11-az3.${local.endpoint_prefix}${var.region}.hs-crypto.cloud.ibm.com"
    hs-crypto-kmip              = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:kmip.${local.endpoint_prefix}${var.region}.hs-crypto.cloud.ibm.com"
    hs-crypto-tke               = "crn:v1:bluemix:public:hs-crypto:${var.region}:::endpoint:tke.${local.endpoint_prefix}${var.region}.hs-crypto.cloud.ibm.com"
    iam-svcs                    = "crn:v1:bluemix:public:iam-svcs:global:::endpoint:${local.endpoint_prefix}iam.cloud.ibm.com"
    is                          = "crn:v1:bluemix:public:is:${var.region}:::endpoint:${var.region}.${local.endpoint_prefix}iaas.cloud.ibm.com"
    kms                         = "crn:v1:bluemix:public:kms:${var.region}:::endpoint:${local.endpoint_prefix}${var.region}.kms.cloud.ibm.com"
    messaging                   = "crn:v1:bluemix:public:messaging:global:::endpoint:${local.endpoint_prefix}messaging.cloud.ibm.com"
    resource-controller         = "crn:v1:bluemix:public:resource-controller:global:::endpoint:${local.endpoint_prefix}resource-controller.cloud.ibm.com"
    support-center              = "crn:v1:bluemix:public:support:global:::endpoint:private.support-center.cloud.ibm.com"
    transit                     = "crn:v1:bluemix:public:transit:global:::endpoint:${local.endpoint_prefix}transit.cloud.ibm.com"
    user-management             = "crn:v1:bluemix:public:user-management:global:::endpoint:${local.endpoint_prefix}user-management.cloud.ibm.com"
    vmware                      = "crn:v1:bluemix:public:vmware:${var.region}:::endpoint:api.${local.endpoint_prefix}${var.region}.vmware.cloud.ibm.com"
    ntp                         = "ibm-ntp-server"
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
