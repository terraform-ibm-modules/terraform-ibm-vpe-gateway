# Configuring complex inputs for Virtual Private Endpoint Gateways

Several optional input variables in the IBM Cloud [VPE Gateway deployable architecture](https://cloud.ibm.com/catalog#deployable_architecture) use complex object types. You specify these inputs when you configure deployable architecture.

You can specify a set of IBM Cloud services to create VPE endpoint gateways for. At least one of `cloud_services` or `cloud_service_by_crn` must be specified.

- [Cloud Services by name](#cloud-services) (`cloud_services`)
- [Cloud Services by CRN](#cloud-service-by-crn) (`cloud_service_by_crn`)
- [Reserved IPs](#reserved-ips) (`reserved_ips`)

## Cloud Services by name <a name="cloud-services"></a>

You can specify a set of IBM Cloud services by service name to create VPE Endpoint Gateways for. Use `cloud-services` for services that offer general service endpoints.

- Variable name: `cloud_services`.
- Type: A list of objects that represent IBM Cloud services
- Default value: An empty list (`[]`)

### Options for cloud_service

- `service_name` (required): The IBM Cloud service name.
- `vpe_name` (optional): Full control on the VPE name. If not specified, the VPE name will be computed based on prefix, vpc name and service name.
- `allow_dns_resolution_binding` (optional): Indicates whether to allow this endpoint gateway to participate in DNS resolution bindings with a VPC that has dns.enable_hub set to true.

### Example service credential

```hcl
[
  {
    "service_name": "kms",
    "vpe_name": "kms-gateway",
    "allow_dns_resolution_binding": false
  },
  {
    "service_name": "cloud-object-storage"
  }
]
```

## Cloud Service by CRN <a name="cloud-service-by-crn"></a>

You can specify a set of IBM Cloud services by CRN to create VPE Endpoint Gateways for. Use `cloud-service-by-crn` for services that generate instance specific VPE gateway targets.

- Variable name: `cloud_service_by_crn`.
- Type: A list of objects that represent IBM Cloud services
- Default value: An empty list (`[]`)

### Options for cloud_service_by_crn

- `crn` (required): IBM Cloud service CRN.
- `vpe_name` (optional): Full control on the VPE name. If not specified, the VPE name will be computed based on prefix, vpc name and service name.
- `service_name` (optional):
- `allow_dns_resolution_binding` (optional): Indicates whether to allow this endpoint gateway to participate in DNS resolution bindings with a VPC that has dns.enable_hub set to true.

### Example cloud_service_by_crn

```hcl
[
  {
    "crn": "crn:version:cname:ctype:service-name:location:scope:service-instance::",
    "vpe_name": "service-gateway",
    "service_name": "service-name",
    "allow_dns_resolution_binding": false
  },
  {
    "crn": "crn:version:cname:ctype:service-name:location:scope:service-instance::"
  }
]
```

## Reserved IPs <a name="reserved-ips"></a>

Map of existing reserved IP names and values. If you wish to create your reserved ips independently and not create new ones you can first run the `reserved-ips` submodule and then copy the output `reserved_ip_map` here."

- Variable name: `reserved_ips`
- Type: A map of existing reserved IP names and ids
- Default value: An empty map (`{}`)

### Example reserved IPs

The following example shows values for both disk and memory for the `reserved_ips` input.

```hcl
{
  "vpc-cloud-object-storage-1" = "0717-12345678-1234-1234-1234-123456789abc"
  "vpc-cloud-object-storage-2" = "0727-12345678-1234-1234-1234-123456789abc"
  "vpc-cloud-object-storage-3" = "0737-12345678-1234-1234-1234-123456789abc"
  "vpc-kms-1" = "0717-12345678-1234-1234-1234-123456789abc"
  "vpc-kms-2" = "0727-12345678-1234-1234-1234-123456789abc"
  "vpc-kms-3" = "0737-12345678-1234-1234-1234-123456789abc"
}
```
