# IBM Virtual Private Endpoints module

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-vpe-module?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-vpe-module/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module creates and configures virtual private endpoint gateways (https://cloud.ibm.com/docs/vpc?topic=vpc-ordering-endpoint-gateway) for an IBM Cloud service.

The module supports the following actions:
- Create virtual private endpoint gateways
- Create reserved IP addresses
- Attach endpoint gateways to reserved IP addresses

## Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

# Creates:
# - VPE
module "vpes" {
  source           = "terraform-ibm-modules/vpe-module/ibm"
  version          = "latest" # Replace "latest" with a release version to lock into a specific release
  region           = "us-south"
  prefix           = "vpe"
  vpc_name         = "my-vpc-instance"
  vpc_id           = "r022-ae2a6785-gd62-7d4j-af62-b4891e949345"
  subnet_zone_list = [
    {
      name           = "subnet-1"
      cidr           = "10.0.10.0/24"
      public_gateway = true
      acl_name       = "acl"
    },
    {
      name           = "subnet-2"
      cidr           = "10.0.11.0/24"
      acl_name       = "acl"
      public_gateway = null
    }
  ]
  resource_group_id    = "00ae4b38253f43a3acd14619dd385632" # pragma: allowlist secret
  security_group_ids   = ["r014-2d4f8cd6-6g3s-4ab5-ac3f-8fc717ce2a1f"]
  cloud_services       = ["kms", "cloud-object-storage"]
  cloud_service_by_crn = [
    {
      name = "subnet-1"
      crn  = "crn:v1:bluemix:public:kms:au-syd:a/abac0df06b644a9cabc6e44f55b3880e:12d2244b-g3d3-4978-7s3f-81b60a1fb7a4::"
    },
  ]
  service_endpoints = "private"
}
```

## Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM services
    - **VPE Infrastructure** services
        - `Editor` platform access

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ End-to-end example](examples/default)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.52.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_is_subnet_reserved_ip.ip](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_subnet_reserved_ip) | resource |
| [ibm_is_virtual_endpoint_gateway.vpe](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_virtual_endpoint_gateway) | resource |
| [ibm_is_virtual_endpoint_gateway_ip.endpoint_gateway_ip](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_virtual_endpoint_gateway_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_service_by_crn"></a> [cloud\_service\_by\_crn](#input\_cloud\_service\_by\_crn) | List of cloud service CRNs. Each CRN will have a unique endpoint gateways created. For a list of supported services, see the docs [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services). | <pre>list(<br>    object({<br>      name = string # service name<br>      crn  = string # service crn<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_cloud_services"></a> [cloud\_services](#input\_cloud\_services) | List of cloud services to create an endpoint gateway. | `list(string)` | <pre>[<br>  "kms",<br>  "cloud-object-storage"<br>]</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix that you would like to append to your resources | `string` | `"vpe"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where VPC and services are deployed | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of the resource group where endpoint gateways will be provisioned | `string` | `null` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group ids to attach to each endpoint gateway. | `list(string)` | `null` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | Service endpoints to use to create endpoint gateways. Can be `public`, or `private`. | `string` | `"private"` | no |
| <a name="input_subnet_zone_list"></a> [subnet\_zone\_list](#input\_subnet\_zone\_list) | List of subnets in the VPC where gateways and reserved IPs will be provisioned. This value is intended to use the `subnet_zone_list` output from the Landing Zone VPC Subnet Module (https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc) or from templates using that module for subnet creation. | <pre>list(<br>    object({<br>      name = string<br>      id   = string<br>      zone = optional(string)<br>      cidr = optional(string)<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the Endpoint Gateways will be created | `string` | `null` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC where the Endpoint Gateways will be created. This value is used to dynamically generate VPE names. | `string` | `"vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_crn"></a> [crn](#output\_crn) | The CRN of the endpoint gateway |
| <a name="output_vpe_ips"></a> [vpe\_ips](#output\_vpe\_ips) | The endpoint gateway reserved ips |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
