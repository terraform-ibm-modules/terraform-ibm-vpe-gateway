# Reserved IPs Module

The module creates a set of reserved IPs (https://cloud.ibm.com/docs/vpc?topic=vpc-managing-ip-addresses) on VPC existing subnets. Reserved IPs can be assigned to your resources, for example Virtual Private Endpoint gateways.

The module supports the following actions:
- Create reserved IP addresses

It supports two different ways to specify the Reserved IPs to create:
- by filling the input parameter `var.endpoint_ip_list` with a list of elements with the following attributes:
   - `ip_name`: unique name to use for the key of the map representing the reserved IPs structure in output
   - `subnet_id`: ID of the VPC subnet to create the reserved IP
   - `name`: name of the Reserved IP resource name
- by filling the input parameters `var.subnet_zone_list`, `var.reserved_ip_cloud_services` and `var.cloud_service_by_crn` with the respective attributes: the module logic combines the two lists `var.reserved_ip_cloud_services` and `var.cloud_service_by_crn` into a single list of services by extracting the expected services details and then combines this list with the `var.subnet_zone_list` list to allocate a Reserved IP for each subnet and for each service, by generating a unique `ip_name` key for each element of the map

In both the cases the output of the module is:
- `endpoint_ip_list` with the map of service name & subnet ID to create and bind to the Reserved IPs as map values of the related map key
- `reserved_ip_map` with the map of the Reserved IPs resources created for each of the service name & subnet ID elements of the previous list, mapped by the unique map key.

The module supports also you to associate existing Reserved IPs resources from your VPC through `var.reserved_ips` with specific gateways: in order to associate an existing Reserved IP to a specific gateway add an element to this list with two attributes, the unique map key used or generated for the `endpoint_ip_list` and the related Reserved IP instance to associate it with.

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

# - Reserved IP
module "ip" {
  source           = "terraform-ibm-modules/vpe-gateway/ibm//modules/reserved-ips"
  cloud_services = [
    {
      service_name = "kms"
    },
    {
      service_name = "cloud-object-storage"
    }
  ]
  subnet_zone_list = [
    [
      {
        "id" = "0717-6ff0a6fb-e180-4048-9daf-a2f99f8740cd"
        "name" = "vpe-vpc-instance-subnet-a"
        "zone" = "us-south-1"
      }
    ],
    [
      {
        "id" = "0727-c402f19e-ee68-41b6-90f0-a17d51f629ff"
        "name" = "vpe-vpc-instance-subnet-b"
        "zone" = "us-south-2"
      }
    ],
    [
      {
        "id" = "0737-323dc004-19c5-4d27-b5bc-028b1189a316"
        "name" = "vpe-vpc-instance-subnet-c"
        "zone" = "us-south-3"
      }
    ],
  ]
  region           = "us-south"
  prefix           = "vpe-default"
  vpc_name         = "vpc-instance"
}
```

The above will create 6 new reserved ips as such and output them:
```
  reserved_ips = {
    "vpe-vpc-cloud-object-storage-1" = "0717-13bea57a-61cd-4c91-bc17-77e0a1088283"
    "vpe-vpc-cloud-object-storage-2" = "0727-5d84bf9a-20ca-4592-9f8c-b8c2d0e7f5ac"
    "vpe-vpc-cloud-object-storage-3" = "0737-6a6a353d-16d0-4aaf-a46f-14f312363a62"
    "vpe-vpc-kms-1" = "0717-d00e85c2-4e6a-43ef-81a7-58f69ecc70af"
    "vpe-vpc-kms-2" = "0727-bd171da2-f4d6-4f12-906f-8157f16a03ad"
    "vpe-vpc-kms-3" = "0737-8e2485dd-9ca9-4818-bfc7-9a5861901de3"
  }
```

### Required IAM access policies
You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **VPC Infrastructure Services** service
        - `Editor` platform access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.81.1, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_is_subnet_reserved_ip.ip](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_subnet_reserved_ip) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_service_by_crn"></a> [cloud\_service\_by\_crn](#input\_cloud\_service\_by\_crn) | List of cloud service CRNs. Each CRN will have a unique endpoint gateways created. For a list of supported services, see the docs [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services). | <pre>list(<br/>    object({<br/>      name = string # service name<br/>      crn  = string # service crn<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_endpoint_ip_list"></a> [endpoint\_ip\_list](#input\_endpoint\_ip\_list) | List of IPs to create. Each object contains an ip name and subnet id | <pre>list(<br/>    object({<br/>      ip_name   = string # reserved ip name<br/>      subnet_id = string # subnet id<br/>      name      = string # ip name<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix that you would like to append to your resources. Value is only used if no value is passed for the `vpe_name` option in the `reserved_ip_cloud_services` input variable. | `string` | `"vpe"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to be used in the reserved ip naming convention. | `string` | `"us-south"` | no |
| <a name="input_reserved_ip_cloud_services"></a> [reserved\_ip\_cloud\_services](#input\_reserved\_ip\_cloud\_services) | List of cloud services to create reserved ips for. The keys are the service names, the values (all optional) give some level of control on the created VPEs. | <pre>set(object({<br/>    service_name = string<br/>    vpe_name     = optional(string),<br/>  }))</pre> | `[]` | no |
| <a name="input_reserved_ips"></a> [reserved\_ips](#input\_reserved\_ips) | Map of existing reserved IP names and values. Leave this value as default if you want to create new reserved ips, this value is used in the main module in which a user passes their existing reserved ips created here so as to not attempt to recreate them. | <pre>object({<br/>    name = optional(string) # reserved ip name<br/>  })</pre> | `{}` | no |
| <a name="input_subnet_zone_list"></a> [subnet\_zone\_list](#input\_subnet\_zone\_list) | List of subnets in the VPC where reserved IPs will be provisioned. `name`, and `zone` are used in the naming convention of the reserved ip's which are then assigned to the subnet `id`. This value is intended to use the `subnet_zone_list` output from the Landing Zone VPC Subnet Module (https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc) or from templates using that module for subnet creation. | <pre>list(<br/>    object({<br/>      name = string<br/>      id   = string<br/>      zone = optional(string)<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC that will be used in naming the newly created reserved ip(s). Value is only used if no value is passed for the `vpe_name` option in the `reserved_ip_cloud_services` input variable. | `string` | `"vpc"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_ip_list"></a> [endpoint\_ip\_list](#output\_endpoint\_ip\_list) | The endpoint gateway reserved ips |
| <a name="output_reserved_ip_map"></a> [reserved\_ip\_map](#output\_reserved\_ip\_map) | The endpoint gateway reserved ips |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
