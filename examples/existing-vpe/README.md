# Existing VPE Gateway adoption example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpe-gateway-existing-vpe-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpe-gateway/tree/main/examples/existing-vpe">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->


This example demonstrates the **shared VPE Gateway** pattern: one Terraform
workspace (the *owner*) creates the gateway and manages it fully, while one or
more other workspaces (the *consumers*) adopt the same gateway by providing its
ID via the `existing_vpe_id` field in `cloud_service_by_crn`. Consumers only
create and manage their own reserved-IP bindings; they **never** destroy the
shared gateway.

## Why this matters

Multiple IKS/ROKS clusters (or any workloads) in the same VPC may need to reach
the same service through a single VPE Gateway. Creating a second gateway for the
same CRN in the same VPC is wasteful and may be disallowed by the platform.
With `existing_vpe_id` each consumer workspace can bind its own subnets to the
shared gateway independently. Tearing down a consumer workspace removes only
that workspace's reserved IPs; the gateway and all other bindings remain.

## Usage

```hcl
# ── Owner workspace ───────────────────────────────────────────────────────────
module "vpe_owner" {
  source           = "terraform-ibm-modules/vpe-gateway/ibm"
  version          = "X.X.X"
  region           = "us-south"
  prefix           = "owner"
  vpc_name         = "my-vpc"
  vpc_id           = ibm_is_vpc.vpc.id
  subnet_zone_list = local.subnet_zone_list
  cloud_service_by_crn = [
    {
      crn          = "crn:v1:bluemix:public:backuprecovery:us-south:a/..."
      service_name = "backup-recovery"
    }
  ]
}

# ── Consumer workspace ────────────────────────────────────────────────────────
# Obtain the gateway ID from the owner's remote state or a data source.
data "ibm_is_virtual_endpoint_gateway" "shared_brs" {
  name = "owner-my-vpc-backup-recovery"
}

module "vpe_consumer" {
  source           = "terraform-ibm-modules/vpe-gateway/ibm"
  version          = "X.X.X"
  region           = "us-south"
  prefix           = "consumer"
  vpc_name         = "my-vpc"
  vpc_id           = ibm_is_vpc.vpc.id
  subnet_zone_list = local.consumer_subnet_zone_list
  cloud_service_by_crn = [
    {
      crn             = data.ibm_is_virtual_endpoint_gateway.shared_brs.target[0].crn
      vpe_name        = "owner-my-vpc-backup-recovery"   # must match existing name
      service_name    = "backup-recovery"
      existing_vpe_id = data.ibm_is_virtual_endpoint_gateway.shared_brs.id
    }
  ]
}
```

## Behaviour summary

| Field | Owner call | Consumer call |
|---|---|---|
| `existing_vpe_id` | not set (gateway is created) | set to the gateway's ID |
| Gateway lifecycle | created & destroyed with module | **never destroyed** |
| Reserved IPs | created & destroyed | created & destroyed |
| `vpe_ips` output | populated | populated (adopted gateway) |
| `crn` output | populated | populated (adopted gateway CRN) |
