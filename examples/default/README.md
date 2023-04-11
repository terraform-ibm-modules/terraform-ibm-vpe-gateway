# End to end example

This example creates the following infrastructure:
 - A resource group, if one is not passed in.
 - A VPC, if one is not passed in.
   - The VPC that is created has got 3 subnets across the 3 availability zones of the region that is passed as input.
 - Create a new security group in the VPC
   - The security group has got one single inbound rule allowing traffic from resources attached to the default VPC security group. This rule is added as an example.
 - Two virtual private endpoint (VPE) gateways - one VPE to COS and another VPE to Key protect by default (configurable through the `service_endpoints` input)
   - Each of the two virtual private endpoint gateways are attached to the 3 VPC subnets.
   - Attach the new security group created above to the two VPE gateways
