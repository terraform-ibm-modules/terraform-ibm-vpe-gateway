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
# Lookups for Existing VPE and VPC details
##############################################################################
data "ibm_is_virtual_endpoint_gateway" "existing_vpe" {
  name = var.existing_vpe_name
}

data "ibm_is_vpc" "vpc" {
  identifier = data.ibm_is_virtual_endpoint_gateway.existing_vpe.vpc
}

locals {
  # Dynamically derive the subnet_zone_list from the VPC's subnets,
  # filtering out subnets that are already bound to the existing VPE
  subnet_zone_list = [
    for subnet in data.ibm_is_vpc.vpc.subnets :
    {
      id   = subnet.id
      name = subnet.name
      zone = subnet.zone
    }
    if !contains([for ip in data.ibm_is_virtual_endpoint_gateway.existing_vpe.ips : ip.subnet], subnet.id)
  ]
}

##############################################################################
# Consume/Adopt an existing pre-created VPE Gateway (Shared VPE Pattern)
#
# This stack is a "pure consumer" that runs in the same VPC. It does not
# create or destroy the VPE gateway itself, but provisions and attaches
# new reserved IPs to the pre-existing gateway.
##############################################################################
module "vpes_consumer" {
  source            = "../../../"
  region            = var.region
  prefix            = var.prefix
  vpc_name          = data.ibm_is_vpc.vpc.name
  vpc_id            = data.ibm_is_vpc.vpc.id
  subnet_zone_list  = local.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id
  resource_tags     = var.resource_tags
  access_tags       = var.access_tags
  cloud_services = [
    {
      service_name    = var.service_name
      vpe_name        = var.existing_vpe_name
      existing_vpe_id = var.existing_vpe_id
    }
  ]
}
