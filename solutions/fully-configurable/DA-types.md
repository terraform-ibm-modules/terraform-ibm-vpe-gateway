# Configuring complex inputs for Virtual Private Endpoint Gateways

IBM Cloud® Virtual Private Endpoints (VPE) for VPC enables you to connect to supported IBM Cloud services from your Virtual Private Cloud (VPC) network by using the IP addresses of your choosing, allocated from a subnet within your VPC. For more details about Virtual Private Endpoint Gateways please refer to this [documentation page](https://cloud.ibm.com/docs/vpc?topic=vpc-about-vpe)

IBM Cloud services either offer a service specific target or an instance specific target for the VPE gateway. In order to target a service specific endpoint, the service should be included in the `cloud_services` block. In order to target an instance specific endpoint the service CRN should be included in the `cloud_service_by_crn` block.

For more details about the IBM Cloud services, their VPE configuration information and about creating gateways to Non-IBM Cloud services please refer to [this documentation page](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services)

As alternative, the CLI command `ibmcloud is endpoint-gateway-targets` returns a list of IBM Cloud services supported in a specific region, including the services' names and their CRNs

- [cloud_services](#cloud-services) : this input parameter allows to create a VPE gateway to a IBM Cloud service by specifying its service name
- [cloud_service_by_crn](#cloud-service-by-crn) : this input parameter allows to create a VPE gateway to a IBM Cloud service its service CRN (Cloud Resource Name)

## VPE gateway to Cloud Services by service name <a name="cloud-services"></a>

By setting up this input parameter you can create VPE gateways in your VPC instance by specifying the name of the IBM Cloud services.

**Important note: ** you can use this structure only for IBM Cloud services offering global service endpoints.

- Variable name: `cloud_services`.
- Type: A list of objects that represent IBM Cloud services with attributes `service_name`, `vpe_name` and `dns_resolution_binding_mode`
- Default value: the default value is an empty list (`[]`)

### cloud_service attributes

- `service_name` (required): The IBM Cloud service name as per [this documentation page](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services) or the name value returned by the CLI command `ibmcloud is endpoint-gateway-targets`
- `vpe_name` (optional): The desired name to assign to the VPE gateway. If not specified, the VPE name will be computed based on prefix, vpc name and service name.
- `dns_resolution_binding_mode` (optional): Indicates the DNS resolution binding mode used for the endpoint gateway. For more details please refer to this [documentation page](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-dns-sharing-configure-hub&interface=ui). If not set default value is `disabled`.

### Example for cloud_services input parameter

```hcl
[
  {
    "service_name": "global-search-tagging",
    "vpe_name": "global-search-gateway",
    "dns_resolution_binding_mode": "disabled"
  },
  {
    "service_name": "cloud-object-storage"
  }
]
```

## VPE gateway to Cloud Services by service CRN <a name="cloud-service-by-crn"></a>

By setting up this input parameter you can create VPE gateways in your VPC instance by specifying the IBM Cloud services CRNs.

- Variable name: `cloud_service_by_crn`.
- Type: A list of objects that represent IBM Cloud services with attributes `crn`, `vpe_name`, `service_name` and `dns_resolution_binding_mode`
- Default value: the default value is an empty list (`[]`)

### Options for cloud_service_by_crn

- `crn` (mandatory): IBM Cloud service CRN as per [this documentation page](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services) or the CRN value returned by the CLI command `ibmcloud is endpoint-gateway-targets`
- `vpe_name` (optional): The desired name to assign to the VPE gateway. If not specified, the VPE name will be computed based on prefix, vpc name and service name.
- `service_name` (optional): The name of the service used to compute the name of the VPE gateway. If not provided the name is extracted from the CRN.
- `dns_resolution_binding_mode` (optional): Indicates the DNS resolution binding mode used for the endpoint gateway. For more details please refer to this [documentation page](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-dns-sharing-configure-hub&interface=ui). If not set default value is `primary`.

### Example for cloud_service_by_crn

```hcl
[
  {
    "crn": "crn:v1:bluemix:public:kms:eu-es:::endpoint:private.eu-es.kms.cloud.ibm.com",
    "vpe_name": "kms-eu-es-gateway",
    "service_name": "kms",
    "dns_resolution_binding_mode": "primary"
  },
  {
    "crn": " crn:v1:bluemix:public:iam-svcs:global:::endpoint:private.iam.cloud.ibm.com"
  }
]
```
