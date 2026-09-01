##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.6.1"
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create a VPC for this example
##############################################################################
module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "10.0.1"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
  resource_tags     = var.resource_tags
}

##############################################################################
# Creates the shared VPE Gateway (Owner Workspace)
# Binds only ONE subnet (the first subnet) to the gateway initially.
##############################################################################
module "vpes_owner" {
  source            = "../../../"
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = [module.vpc.subnet_zone_list[0]] # Only bind the first subnet
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
  cloud_services = [
    {
      service_name = var.service_name
    }
  ]
}
