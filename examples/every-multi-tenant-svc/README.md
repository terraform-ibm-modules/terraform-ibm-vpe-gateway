# Every supported multi-tenant ("provider_cloud_service") VPE gateway

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=vpe-gateway-every-multi-tenant-svc-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-vpe-gateway/tree/main/examples/every-multi-tenant-svc"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


This example creates the following infrastructure:
- A resource group, if one is not passed in.
- A VPC
    - The VPC is created with three subnets across the three availability zones of the region that is passed as input.
- A virtual private endpoint (VPE) gateways for EVERY multitenant service supported

> [!WARNING]
> Creating all service VPEs in one apply may cause the VPC to enter "locked" state, and some endpoints may fail to be created.
> In this scenario you can keep re-applying until all endpoints are created, or execute your `terraform apply` using the
> `-parallelism=n` option with a small thread number to avoid the lock.
>
> [IBM Terraform provider issue reporting this issue](https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6224)

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
