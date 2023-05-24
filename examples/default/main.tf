##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create a VPC for this example using defaults from terraform-ibm-landing-zone-vpc
# ( 3 subnets across the 3 AZs in the region )
##############################################################################

module "vpc" {
  count             = var.vpc_id != null ? 0 : 1
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc.git?ref=v7.0.1"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = var.vpc_name
  tags              = var.resource_tags
}

##############################################################################
# Demonstrate how to create a custom security group that is applied to the VPEs
# This examples allow all workload associated with the default VPC security group
# to interact with the VPEs
##############################################################################

data "ibm_is_vpc" "vpc" {
  # Explicit depends as the vpc_name is known prior to VPC creation
  depends_on = [
    module.vpc
  ]
  name = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_name
}

data "ibm_is_security_group" "default_sg" {
  name = data.ibm_is_vpc.vpc.default_security_group_name
}

module "vpe_security_group" {
  source                       = "git::https://github.com/terraform-ibm-modules/terraform-ibm-security-group.git?ref=v1.0.0"
  security_group_name          = "${var.prefix}-vpe-sg"
  add_ibm_cloud_internal_rules = false # No need for the internal ibm cloud rules for SG associated with VPEs

  security_group_rules = [{
    name      = "allow-all-default-sg-inbound"
    direction = "inbound"
    remote    = data.ibm_is_security_group.default_sg.id
  }]

  resource_group = module.resource_group.resource_group_id
  vpc_id         = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
}

##############################################################################
# Create VPEs in the VPC
##############################################################################
module "vpes" {
  source               = "../../"
  region               = var.region
  prefix               = var.prefix
  vpc_name             = var.vpc_name
  vpc_id               = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  subnet_zone_list     = var.vpc_id != null ? var.subnet_zone_list : module.vpc[0].subnet_zone_list
  resource_group_id    = module.resource_group.resource_group_id
  security_group_ids   = var.security_group_ids != null ? var.security_group_ids : [module.vpe_security_group.security_group_id]
  cloud_services       = var.cloud_services
  cloud_service_by_crn = var.cloud_service_by_crn
  service_endpoints    = var.service_endpoints
  #  Wait 30secs after security group is destroyed before destroying VPE to workaround timing issue which can produce “Target not found” error on destroy
  depends_on = [time_sleep.wait_30_seconds]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on       = [data.ibm_is_security_group.default_sg]
  create_duration  = "120s"
  destroy_duration = "60s"
}


##############################################################################
