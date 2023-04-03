##############################################################################
# Create a VPC for this example
##############################################################################

module "vpc" {
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc.git?ref=v5.0.1"
  resource_group_id = var.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = var.vpc_name
}


##############################################################################
# Create VPEs in the VPC
##############################################################################
module "vpes" {
  source   = "../../"
  region   = var.region
  prefix   = var.prefix
  vpc_name = var.vpc_name
  vpc_id   = module.vpc.vpc_id
  # Attach VPEs to all subnets in the VPC in this example
  subnet_zone_list     = module.vpc.subnet_zone_list
  resource_group_id    = var.resource_group_id
  security_group_ids   = var.security_group_ids
  cloud_services       = var.cloud_services
  cloud_service_by_crn = var.cloud_service_by_crn
  service_endpoints    = var.service_endpoints
}

##############################################################################
