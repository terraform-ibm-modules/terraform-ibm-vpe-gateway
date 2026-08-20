##############################################################################
# Existing VPE Gateway example
#
# This example demonstrates the "shared VPE Gateway" pattern:
#   - Workspace A (owner) creates a VPE Gateway for a service (e.g.
#     cloud-object-storage) and manages it fully.
#   - Workspace B (consumer) reuses that same existing gateway by passing its
#     name via `vpe_name` and `existing_vpe_id`. Workspace B only creates and
#     manages its own reserved-IP bindings; the gateway itself is NOT destroyed
#     when workspace B runs `terraform destroy`.
#
# In this example both roles are shown in a single configuration for
# illustration purposes. In real use they would be separate Terraform root
# modules / workspaces sharing state via remote_state or data sources.
##############################################################################

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
# Create a VPC (3 subnets across 3 AZs)
##############################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "9.2.3"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  prefix            = var.prefix
  name              = "vpc"
  resource_tags     = var.resource_tags
}

##############################################################################
# ── OWNER workspace ──────────────────────────────────────────────────────────
# Creates the VPE Gateway for the shared service (cloud-object-storage here).
# In a real topology this would live in its own root module / workspace.
##############################################################################

module "vpe_owner" {
  source            = "../../"
  region            = var.region
  prefix            = var.prefix
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id
  cloud_services = [
    {
      # The owner creates and fully manages this gateway.
      service_name = "cloud-object-storage"
    }
  ]
}

##############################################################################
# ── CONSUMER workspace ───────────────────────────────────────────────────────
# Reuses the existing gateway created by the owner and attaches its own
# reserved IPs to it. On `terraform destroy` only the reserved IPs owned by
# this module call are removed; the gateway itself is left intact.
#
# In a real consumer workspace the gateway name would come from a remote state
# output or a convention agreed between teams.
##############################################################################

# Look up the existing gateway by name so the consumer module can pass its CRN.
# depends_on ensures this data source is not evaluated until the owner module
# has fully applied (gateway stable).
data "ibm_is_virtual_endpoint_gateway" "shared_cos" {
  depends_on = [module.vpe_owner]
  name       = "${var.prefix}-vpc-cloud-object-storage"
}

module "vpe_consumer" {
  source            = "../../"
  region            = var.region
  prefix            = "${var.prefix}-consumer"
  vpc_name          = module.vpc.vpc_name
  vpc_id            = module.vpc.vpc_id
  subnet_zone_list  = module.vpc.subnet_zone_list
  resource_group_id = module.resource_group.resource_group_id

  cloud_service_by_crn = [
    {
      # Use the existing gateway instead of creating a new one.
      # Only reserved-IP bindings are created/destroyed by this module call.
      crn          = data.ibm_is_virtual_endpoint_gateway.shared_cos.target[0].crn
      vpe_name     = "${var.prefix}-vpc-cloud-object-storage" # must match the existing gateway name exactly
      service_name = "cloud-object-storage"
      # existing_vpe_id is no longer used by the root module (lookup is by name),
      # but the field is kept here to document intent and satisfy the variable contract.
      existing_vpe_id = data.ibm_is_virtual_endpoint_gateway.shared_cos.id
    }
  ]

  # Ensure the consumer module runs only after the owner gateway is fully
  # stable and the shared_cos data source has resolved.
  depends_on = [module.vpe_owner]
}

##############################################################################
