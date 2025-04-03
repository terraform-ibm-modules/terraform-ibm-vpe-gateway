# Deploy Virtual Private Endpoint (VPE) gateways to Virtual Private Cloud (VPC)

This architecture creates and configures virtual private endpoint gateways to virtual private cloud. 

## Before you begin

* You must have a Virtual Private Cloud instance.

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
