##############################################################################
# Call Root Module
##############################################################################
module "vpe" {
  source               = "../../"
  region               = var.region
  prefix               = var.prefix
  vpc_name             = var.vpc_name
  vpc_id               = var.vpc_id
  subnet_zone_list     = var.subnet_zone_list
  resource_group_id    = var.resource_group_id
  security_group_ids   = var.security_group_ids
  cloud_services       = var.cloud_services
  cloud_service_by_crn = var.cloud_service_by_crn
  service_endpoints    = var.service_endpoints
  create_vpc           = var.create_vpc
}

##############################################################################
