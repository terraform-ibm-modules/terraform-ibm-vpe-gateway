# Existing Reserved IPs example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpe-gateway-reserved-ips-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpe-gateway/tree/main/examples/reserved-ips"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


This example creates reserved ips in the example and passes those values to the main modules `reserved_ips` variable which will use those existing reserved ips instead of creating new values.

This example creates the following infrastructure:
- A resource group, if one is not passed in.
- A VPC, if one is not passed in.
    - The VPC is created with three subnets across the three availability zones of the region that is passed as input.
- A security group in the VPC.
    - The security group is created with a single inbound rule that allows traffic from resources that are attached to the default VPC security group. This rule is added as an example.
- The reserved IPs are created. These are later passed to the gateway as an example of how the reserved IPs module could be used.
- Two virtual private endpoint (VPE) gateways. By default, one VPE to COS and another VPE to Key Protect are created. You can change the defaults by using the `service_endpoints` input.
    - Each of the two virtual private endpoint gateways are attached to the three VPC subnets.
    - The new security group is attached to the two VPE gateways.
    - Passes existing reserved ip values to be used instead of creating new ones.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
