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
  create_duration = "180s"
  depends_on      = [module.vpc]
}

##############################################################################
# Create every multi-tenant VPEs in the VPC
# NOTE: forcing a shorter VPE name for some services due to length limitations
# on VPE service side
##############################################################################

module "vpes" {
  source            = "../../"
  depends_on        = [time_sleep.sleep_time]
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
    }
  ]
}
##############################################################################
