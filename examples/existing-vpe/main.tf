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
# Consumer — reuses an existing gateway, manages only its own reserved IPs
# The gateway is looked up by name from var.existing_vpe_name.
# On terraform destroy only the reserved IPs are removed; the gateway is left intact.
##############################################################################

data "ibm_is_virtual_endpoint_gateway" "shared_vpe" {
  name = var.existing_vpe_name
}

module "vpe_consumer" {
  source            = "../../"
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_service_by_crn = [
    {
      crn             = data.ibm_is_virtual_endpoint_gateway.shared_vpe.target[0].crn
      vpe_name        = var.existing_vpe_name # must match the existing gateway name
      existing_vpe_id = data.ibm_is_virtual_endpoint_gateway.shared_vpe.id
    }
  ]
}

##############################################################################
