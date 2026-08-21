# Existing VPE Gateway example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpe-gateway-existing-vpe-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpe-gateway/tree/main/examples/existing-vpe">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

This example demonstrates reusing a pre-existing VPE Gateway using the `existing_vpe_id` field. It creates the following infrastructure:
- A resource group, if one is not passed in.
- A VPC with three subnets across the three availability zones of the region that is passed as input.
- Reserved IPs bound to a pre-existing VPE Gateway supplied via `existing_vpe_name`. No new gateway is created.
    - On `terraform destroy`, only the reserved IPs are removed; the shared gateway itself is left intact.
