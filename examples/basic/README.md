# Basic multi-tenant VPE gateway

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpe-gateway-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpe-gateway/tree/main/examples/basic">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

This example creates the following infrastructure:
- A resource group, if one is not passed in.
- A VPC
    - The VPC is created with three subnets across the three availability zones of the region that is passed as input.
- A virtual private endpoint (VPE) gateways for a couple of the  multitenant services
