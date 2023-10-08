### randomising the custom vpe names
locals {
  vpe_names = {
    for k, v in var.vpe_names :
    k => "${var.prefix}-${v}"
  }
}

##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.0.6"
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
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "7.5.0"
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
  source                       = "terraform-ibm-modules/security-group/ibm"
  version                      = "2.0.0"
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
# Create a PostgreSQL instance to demonstrate how to create an instance VPE
##############################################################################

module "postgresql_db" {
  source            = "terraform-ibm-modules/icd-postgresql/ibm"
  version           = "3.7.0"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-vpe-pg"
  region            = var.region
}

locals {
  cloud_service_by_crn = concat([{
    name = "postgresql" # name of the vpe
    crn = module.postgresql_db.crn }
  ], var.cloud_service_by_crn)
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
  cloud_service_by_crn = local.cloud_service_by_crn
  service_endpoints    = var.service_endpoints
  vpe_names            = local.vpe_names
  #  See comments below (resource "time_sleep" "sleep_time") for explaination on why this is needed.
  depends_on = [time_sleep.sleep_time]
}

## This sleep serve two purposes:
# 1. Give some extra time after postgresql db creation, and before creating the VPE targetting it. This works around the error "Service does not support VPE extensions."
# 2. Give time on deletion between the VPE destruction and the destruction of the SG that is attached to the VPE. This works around the error "Target not found"
resource "time_sleep" "sleep_time" {
  depends_on       = [module.vpe_security_group.security_group_id, module.postgresql_db]
  create_duration  = "120s"
  destroy_duration = "120s"
}


##############################################################################
