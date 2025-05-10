##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
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
  version           = "7.23.7"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
  tags              = var.resource_tags
}

##############################################################################
# Create every multi-tenant VPEs in the VPC
# NOTE: forcing a shorter VPE name for some services due to length limitations
# on VPE service side
##############################################################################
module "vpes" {
  source            = "../../"
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id
  cloud_services = [
    {
      service_name = "account-management"
    },
    {
      service_name = "billing"
    },
    {
      service_name = "cloud-object-storage"
      vpe_name     = "${var.prefix}-cos"
    },
    {
      service_name = "cloud-object-storage-config"
      vpe_name     = "${var.prefix}-cos-config"
    },
    {
      service_name = "codeengine"
    },
    {
      service_name = "container-registry"
    },
    {
      service_name = "containers-kubernetes"
      vpe_name     = "${var.prefix}-kubernetes"
    },
    {
      service_name = "context-based-restrictions"
      vpe_name     = "${var.prefix}-cbr"
    },
    {
      service_name = "directlink"
    },
    {
      service_name = "dns-svcs"
    },
    {
      service_name = "enterprise"
    },
    {
      service_name = "global-search"
      vpe_name     = "${var.prefix}-search"
    },
    {
      service_name = "global-tagging"
      vpe_name     = "${var.prefix}-tagging"
    },
    {
      service_name = "globalcatalog"
    },
    {
      service_name = "hs-crypto"
    },
    {
      service_name = "hs-crypto-cert-mgr"
    },
    {
      service_name = "hs-crypto-ep11"
    },
    {
      service_name = "hs-crypto-ep11-az1"
    },
    {
      service_name = "hs-crypto-ep11-az2"
    },
    {
      service_name = "hs-crypto-ep11-az3"
    },
    {
      service_name = "hs-crypto-kmip"
    },
    {
      service_name = "hs-crypto-tke"
    },
    {
      service_name = "iam-svcs"
    },
    {
      service_name = "is"
    },
    {
      service_name = "kms"
    },
    {
      service_name = "messaging"
    },
    {
      service_name = "resource-controller"
    },
    {
      service_name = "support-center"
    },
    {
      service_name = "transit"
    },
    {
      service_name = "user-management"
    },
    {
      service_name = "vmware"
    },
    {
      service_name = "ntp"
    }
  ]
}


##############################################################################
