##############################################################################
# Look up existing VPC
##############################################################################

data "ibm_is_vpc" "existing_vpc" {
  name = var.existing_vpc_name
}

##############################################################################
# Adopt existing VPE gateways
##############################################################################

module "adopt_vpe" {
  source               = "../../"
  region               = var.region
  prefix               = var.prefix
  vpc_name             = data.ibm_is_vpc.existing_vpc.name
  vpc_id               = data.ibm_is_vpc.existing_vpc.id
  resource_group_id    = data.ibm_is_vpc.existing_vpc.resource_group
  subnet_zone_list     = var.subnet_zone_list
  cloud_services       = var.cloud_services
  cloud_service_by_crn = var.cloud_service_by_crn
}
