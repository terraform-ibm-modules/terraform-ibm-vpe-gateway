##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
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
  version           = "7.20.2"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
  tags              = var.resource_tags
}

##############################################################################
# Delay to prevent VPC lock when creating many VPEs right after VPC creation
##############################################################################

resource "time_sleep" "sleep_time" {
  create_duration = "300s"
  depends_on      = [module.vpc]
}

##############################################################################
# Create every multi-tenant VPEs in the VPC
# NOTE: * forcing a shorter VPE name for some services due to length limitations
# on VPE service side
# * Since a total of 236 resources will be created that involves VPC in parallel
# than might impact API throttle as well as lock the VPC therefore dividing the
# entire list into smaller batches
##############################################################################

module "vpes_batch_1" {
  source            = "../../"
  depends_on        = [time_sleep.sleep_time]
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    { service_name = "account-management" },
    { service_name = "billing" },
    { service_name = "cloud-object-storage", vpe_name = "${var.prefix}-cos" },
    { service_name = "cloud-object-storage-config", vpe_name = "${var.prefix}-cos-config" }
  ]
}

resource "time_sleep" "sleep_time_batch1_2" {
  create_duration = "120s"
  depends_on      = [module.vpes_batch_1]
}

module "vpes_batch_2" {
  source            = "../../"
  depends_on        = [module.vpes_batch_1, time_sleep.sleep_time_batch1_2]
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    { service_name = "codeengine" },
    { service_name = "container-registry" },
    { service_name = "containers-kubernetes", vpe_name = "${var.prefix}-kubernetes" },
    { service_name = "context-based-restrictions", vpe_name = "${var.prefix}-cbr" }
  ]
}

resource "time_sleep" "sleep_time_batch2_3" {
  create_duration = "120s"
  depends_on      = [module.vpes_batch_2]
}

module "vpes_batch_3" {
  source            = "../../"
  depends_on        = [module.vpes_batch_2, time_sleep.sleep_time_batch2_3]
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    { service_name = "directlink" },
    { service_name = "dns-svcs" },
    { service_name = "enterprise" },
    { service_name = "global-search", vpe_name = "${var.prefix}-search" }
  ]
}

resource "time_sleep" "sleep_time_batch3_4" {
  create_duration = "120s"
  depends_on      = [module.vpes_batch_3]
}

module "vpes_batch_4" {
  source            = "../../"
  depends_on        = [module.vpes_batch_3, time_sleep.sleep_time_batch3_4]
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    { service_name = "global-tagging", vpe_name = "${var.prefix}-tagging" },
    { service_name = "globalcatalog" },
    { service_name = "hs-crypto" },
    { service_name = "hs-crypto-cert-mgr" }
  ]
}

resource "time_sleep" "sleep_time_batch4_5" {
  create_duration = "120s"
  depends_on      = [module.vpes_batch_4]
}

module "vpes_batch_5" {
  source            = "../../"
  depends_on        = [module.vpes_batch_4, time_sleep.sleep_time_batch4_5]
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    { service_name = "hs-crypto-ep11" },
    { service_name = "hs-crypto-ep11-az1" },
    { service_name = "hs-crypto-ep11-az2" },
    { service_name = "hs-crypto-ep11-az3" }
  ]
}

resource "time_sleep" "sleep_time_batch5_6" {
  create_duration = "120s"
  depends_on      = [module.vpes_batch_5]
}

module "vpes_batch_6" {
  source            = "../../"
  depends_on        = [module.vpes_batch_5, time_sleep.sleep_time_batch5_6]
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    { service_name = "hs-crypto-kmip" },
    { service_name = "hs-crypto-tke" },
    { service_name = "iam-svcs" },
    { service_name = "is" }
  ]
}

resource "time_sleep" "sleep_time_batch6_7" {
  create_duration = "120s"
  depends_on      = [module.vpes_batch_6]
}

module "vpes_batch_7" {
  source            = "../../"
  depends_on        = [module.vpes_batch_6, time_sleep.sleep_time_batch6_7]
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    { service_name = "kms" },
    { service_name = "messaging" },
    { service_name = "resource-controller" },
    { service_name = "support-center" }
  ]
}

resource "time_sleep" "sleep_time_batch7_8" {
  create_duration = "120s"
  depends_on      = [module.vpes_batch_7]
}

module "vpes_batch_8" {
  source            = "../../"
  depends_on        = [module.vpes_batch_7, time_sleep.sleep_time_batch7_8]
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    { service_name = "transit" },
    { service_name = "user-management" },
    { service_name = "vmware" },
    { service_name = "ntp" }
  ]
}
##############################################################################
