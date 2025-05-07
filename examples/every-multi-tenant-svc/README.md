# Basic multi-tenant VPE gateway

This example creates the following infrastructure:
- A resource group, if one is not passed in.
- A VPC
    - The VPC is created with three subnets across the three availability zones of the region that is passed as input.
- A virtual private endpoint (VPE) gateways for EVERY multitenant service supported

> [!WARNING]  
> Creating all service VPEs in one apply may cause the VPC to enter "locked" state, and some endpoints may fail to be created.
> In this scenario you can keep re-applying until all endpoints are created, or execute your `terraform apply` using the 
> `-parallelism=n` option with a small thread number to avoid the lock.
