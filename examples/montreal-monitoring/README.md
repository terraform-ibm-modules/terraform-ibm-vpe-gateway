# Multi-tenant IBM Cloud Monitoring in Montreal VPE gateway

This example creates the following infrastructure:
- A resource group, if one is not passed in.
- A VPC
    - The VPC is created with three subnets across the three availability zones of the region that is passed as input.
- A virtual private endpoint (VPE) gateways for a couple of the  multitenant services
