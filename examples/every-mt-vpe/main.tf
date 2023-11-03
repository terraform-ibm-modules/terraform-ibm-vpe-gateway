##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create a VPC for this example using defaults from terraform-ibm-landing-zone-vpc
# ( 3 subnets across the 3 AZs in the region )
##############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "7.7.0"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
}

##############################################################################
# Create every multi-tenant VPEs in the VPC
##############################################################################
module "vpes" {
  source   = "../../"
  region   = var.region
  prefix   = var.prefix
  vpc_name = module.vpc.vpc_name
  vpc_id   = module.vpc.vpc_id
  #subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id
  cloud_services = {
    "account-management"          = {}
    "billing"                     = {}
    "cloud-object-storage"        = {}
    "cloud-object-storage-config" = {}
    "codeengine"                  = {}
    "container-registry"          = {}
    "containers-kubernetes"       = {}
    "context-based-restrictions"  = {}
    "directlink"                  = {}
    "dns-svcs"                    = {}
    "enterprise"                  = {}
    "global-search-tagging"       = {}
    "globalcatalog"               = {}
    "hs-crypto"                   = {}
    "hs-crypto-cert-mgr"          = {}
    "hs-crypto-ep11"              = {}
    "hs-crypto-ep11-az1"          = {}
    "hs-crypto-ep11-az2"          = {}
    "hs-crypto-ep11-az3"          = {}
    "hs-crypto-kmip"              = {}
    "hs-crypto-tke"               = {}
    "hyperp-dbaas-mongodb"        = {}
    "hyperp-dbaas-postgresql"     = {}
    "iam-svcs"                    = {}
    "is"                          = {}
    "kms"                         = {}
    "messaging"                   = {}
    "resource-controller"         = {}
    "support-center"              = {}
    "transit"                     = {}
    "user-management"             = {}
    "vmware"                      = {}
    "ntp"                         = {}
  }
}


##############################################################################
