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
# Create a VPC for this example using defaults from terraform-ibm-landing-zone-vpc
# ( 3 subnets across the 3 AZs in the region )
##############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "10.0.10"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "t"
  resource_tags     = var.resource_tags
}

##############################################################################
# Optionally create a VPE gateway on zone-1 subnet only.
# Used by TestRunExistingGateway to provide an existing_vpe_id for adoption.
# Other tests leave create_vpe=false (default) — zero impact.
##############################################################################

module "vpe" {
  count             = var.create_vpe ? 1 : 0
  source            = "../../"
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  resource_group_id = module.resource_group.resource_group_id
  subnet_zone_list  = [module.vpc.subnet_zone_list[0]]
  cloud_services = [
    { service_name = "kms" }
  ]
}
