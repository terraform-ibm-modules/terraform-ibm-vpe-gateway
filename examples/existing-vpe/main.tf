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
# Adopt an existing VPE gateway
# No new gateway is created; the module manages only the reserved IPs
# and their bindings to the existing gateway.
##############################################################################
module "vpes" {
  source            = "../../"
  region            = var.region
  prefix            = var.prefix
  vpc_name          = var.vpc_name         # existing vpc name
  vpc_id            = var.vpc_id           # existing vpc id
  subnet_zone_list  = var.subnet_zone_list # subnets not already bound to the existing gateway
  resource_group_id = module.resource_group.resource_group_id

  cloud_services = [
    {
      service_name    = var.service_name
      vpe_name        = var.existing_vpe_name
      existing_vpe_id = var.existing_vpe_id
    }
  ]
}

##############################################################################
