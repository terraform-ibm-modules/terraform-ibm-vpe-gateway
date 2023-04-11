# End-to-end example

This example creates the following infrastructure:
- A resource group, if one is not passed in.
- A VPC, if one is not passed in.
    - The VPC is created with three subnets across the three availability zones of the region that is passed as input.
- A security group in the VPC.
    - The security group is created with a single inbound rule that allows traffic from resources that are attached to the default VPC security group. This rule is added as an example.
- Two virtual private endpoint (VPE) gateways. By default, one VPE to COS and another VPE to Key Protect are created. You can change the defaults by using the `service_endpoints` input.
    - Each of the two virtual private endpoint gateways are attached to the three VPC subnets.
    - The new security group is attached to the two VPE gateways.
