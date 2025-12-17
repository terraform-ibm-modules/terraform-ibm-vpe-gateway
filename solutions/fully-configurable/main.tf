########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.4.6"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# VPC
########################################################################################################################

data "ibm_is_vpc" "vpc" {
  name = var.vpc_name
}

data "ibm_is_subnet" "subnet" {
  for_each   = toset(var.subnet_ids)
  identifier = each.key
}

locals {
  subnet_zone_list = [for subnet in data.ibm_is_subnet.subnet : {
    name = subnet.name
    id   = subnet.id
    zone = subnet.zone
  }]
}

########################################################################################################################
# VPE
########################################################################################################################

module "vpe" {
  source               = "../.."
  region               = var.region
  prefix               = var.prefix
  resource_group_id    = module.resource_group.resource_group_id
  vpc_name             = var.vpc_name
  vpc_id               = data.ibm_is_vpc.vpc.id
  subnet_zone_list     = local.subnet_zone_list
  security_group_ids   = var.security_group_ids
  cloud_services       = var.cloud_services
  cloud_service_by_crn = var.cloud_service_by_crn
  service_endpoints    = var.service_endpoints
  reserved_ips         = {} # from a DA usage perspective this map is not needed
}
