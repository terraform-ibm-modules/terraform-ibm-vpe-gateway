# Advanced dedicated service VPE gateway

This example creates the following infrastructure:
- A resource group, if one is not passed in.
- A VPC, if one is not passed in.
    - The VPC is created with three subnets across the three availability zones of the region that is passed as input.
- A security group in the VPC.
    - The security group is created with a single inbound rule that allows traffic from resources that are attached to the default VPC security group. This rule is added as an example.
- Two virtual private endpoint (VPE) gateways are created. One to COS and the other VPE to Key Protect.
    - Each of the two virtual private endpoint gateways are attached to the three VPC subnets.
    - The new security group is attached to the two VPE gateways.
- A dedicated postgresql instance with a VPE gateway from the VPC
