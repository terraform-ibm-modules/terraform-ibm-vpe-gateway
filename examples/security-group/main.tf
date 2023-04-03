##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source              = "git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git?ref=v1.0.5"
  count               = var.resource_group == null ? 1 : 0
  resource_group_name = var.resource_group == null ? "${var.prefix}-resource-group" : null
}

##############################################################################

##############################################################################
# Create VPC
##############################################################################

locals {
  # input variable validation
  # tflint-ignore: terraform_unused_declarations
  validate_vpc_inputs                                = var.vpc_id == null && !var.create_vpc ? tobool("var.create_vpc should be set to true if var.vpc_id is set to null") : true
  # tflint-ignore: terraform_unused_declarations
  validate_vpc_id_and_create_vpc_both_not_set_inputs = var.vpc_id != null && var.create_vpc ? tobool("var.vpc_id cannot be set whilst var.create_vpc is set to true") : true
  vpc_instance_id                                    = var.vpc_id == null ? tolist(ibm_is_vpc.vpc[*].id)[0] : var.vpc_id
  resource_group_id                                  = var.resource_group == null ? module.resource_group.resource_group_id : var.resource_group
}

##############################################################################
# Create a VPC for this example
##############################################################################

resource "ibm_is_vpc" "vpc" {
  count          = var.create_vpc ? 1 : 0
  name           = "${var.prefix}-${var.vpc_name}"
  resource_group = local.resource_group_id
}

##############################################################################
# Update security group
##############################################################################

module "create_sgr_rule" {
  source                       = "git::https://github.com/terraform-ibm-modules/terraform-ibm-security-group.git?ref=v1.0.0"
  add_ibm_cloud_internal_rules = var.add_ibm_cloud_internal_rules
  security_group_name          = "${var.prefix}-1"
  security_group_rules         = var.security_group_rules
  resource_group               = local.resource_group_id
  vpc_id                       = local.vpc_instance_id
}

##############################################################################
# Create VPEs in the VPC
##############################################################################
module "vpes" {
  source               = "../../"
  region               = var.region
  prefix               = var.prefix
  vpc_name             = var.vpc_name
  vpc_id               = local.vpc_instance_id
  subnet_zone_list     = var.subnet_zone_list
  cloud_services       = var.cloud_services
  cloud_service_by_crn = var.cloud_service_by_crn
  service_endpoints    = var.service_endpoints
  security_group_ids   = [module.create_sgr_rule.security_group_id]
  resource_group_id    = local.resource_group_id
}

##############################################################################
