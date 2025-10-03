##############################################################################
# Resource Group
##############################################################################
module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Create a VPC for this example using defaults from terraform-ibm-landing-zone-vpc
# ( 3 subnets across the 3 AZs in the region )
##############################################################################

#module "cloud_monitoring" {
#  source            = "terraform-ibm-modules/cloud-monitoring/ibm"
#  version           = "1.8.1"
#  resource_group_id = module.resource_group.resource_group_id
#  region            = var.region
#  resource_tags     = var.resource_tags
#  instance_name     = "${var.prefix}-cloud-monitoring"
#  plan              = "graduated-tier"
#}

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "7.20.2"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
  tags              = var.resource_tags
}

##############################################################################
# Create every multi-tenant VPEs in the VPC
# NOTE: forcing a shorter VPE name for some services due to length limitations
# on VPE service side
##############################################################################
module "vpes" {
  source = "../../"
  providers = {
    ibm = ibm.montreal
  }
  region            = "ca-mon"
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id
  cloud_services = [
    {
      service_name = "sysdig-monitor"
    }
  ]
  #cloud_service_by_crn = [
  #  {
  #    allow_dns_resolution_binding = false
  #    crn                          = "crn:v1:bluemix:public:sysdig-monitor:eu-gb:a/abac0df06b644a9cabc6e44f55b3880e:1ad66bfa-67cd-45da-af2d-7789d66044eb::"
  #  }
  #]
}


##############################################################################
