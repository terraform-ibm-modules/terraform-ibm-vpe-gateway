##############################################################################
# Existing VPE Gateway example
##############################################################################

##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# VPC
##############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "9.2.3"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
  resource_tags     = var.resource_tags
}

##############################################################################
# Owner — creates and fully manages the VPE Gateway
##############################################################################

module "vpe_owner" {
  source            = "../../"
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id
  cloud_services = [
    {
      service_name = "cloud-object-storage"
    }
  ]
}

##############################################################################
# Consumer — reuses the existing gateway, manages only its own reserved IPs
##############################################################################

# Look up the existing gateway by name; depends_on ensures it exists first
data "ibm_is_virtual_endpoint_gateway" "shared_cos" {
  depends_on = [module.vpe_owner]
  name       = "${var.prefix}-vpc-cloud-object-storage"
}

module "vpe_consumer" {
  source            = "../../"
  region            = var.region
  prefix            = "${var.prefix}-consumer"
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_service_by_crn = [
    {
      crn             = data.ibm_is_virtual_endpoint_gateway.shared_cos.target[0].crn
      vpe_name        = "${var.prefix}-vpc-cloud-object-storage" # must match the existing gateway name
      service_name    = "cloud-object-storage"
      existing_vpe_id = data.ibm_is_virtual_endpoint_gateway.shared_cos.id
    }
  ]
}

##############################################################################
