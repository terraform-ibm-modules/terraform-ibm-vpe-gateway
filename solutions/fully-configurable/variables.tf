variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision resource in."
  nullable    = false
}

variable "region" {
  description = "The region where VPC and services are deployed"
  type        = string
}

variable "prefix" {
  type        = string
  description = "Prefix to add to all resources created by this deployable architecture. To not use any prefix value, you can set this value to `null` or an empty string."
  validation {
    condition = (var.prefix == null ? true :
      alltrue([
        can(regex("^[a-z]{0,1}[-a-z0-9]{0,14}[a-z0-9]{0,1}$", var.prefix)),
        length(regexall("^.*--.*", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter, contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
  }
}

variable "vpc_name" {
  description = "A label that can be used as a short name for virtual private endpoints. If `vpe_name` is not specified in the `cloud_services` or `cloud_service_by_crn` input variable lists, VPE names are created in the format `<prefix>-<vpc_name>-<service_name>`. The value that you specify for `vpc_name` must be known at Terraform plan time."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet ids in the VPC where gateways and reserved IPs will be provisioned."
  type        = list(string)
}

##############################################################################

##############################################################################
# VPE Variables
##############################################################################

variable "security_group_ids" {
  description = "List of security group ids to attach to each endpoint gateway."
  type        = list(string)
  default     = null
}


variable "cloud_services" {
  description = "The list of cloud services used to create endpoint gateways. If `vpe_name` is not specified in the list, VPE names are created in the format `<prefix>-<vpc_name>-<service_name>`. The value that you specify for `vpc_name` must be known at Terraform plan time. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-vpe-gateway/tree/main/solutions/fully-configurable/DA-types.md#cloud_services)."
  type = set(object({
    service_name                 = string
    vpe_name                     = optional(string), # Full control on the VPE name. If not specified, the VPE name will be computed based on prefix, vpc name and service name.
    allow_dns_resolution_binding = optional(bool, false)
  }))
  default = []
  validation {
    error_message = "The service you're trying to add is not supported. For a list of supported services, see [VPE-enabled services](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services). You can add unsupported services in the `cloud_service_by_crn` variable."
    condition = length(var.cloud_services) == 0 ? true : length([
      for service in var.cloud_services :
      service.service_name if !contains([
        "account-management",
        "billing",
        "cloud-object-storage",
        "cloud-object-storage-config",
        "codeengine",
        "container-registry",
        "containers-kubernetes",
        "context-based-restrictions",
        "directlink",
        "dns-svcs",
        "enterprise",
        "global-search-tagging",
        "global-search",
        "global-tagging",
        "globalcatalog",
        "hs-crypto",
        "hs-crypto-cert-mgr",
        "hs-crypto-ep11",
        "hs-crypto-ep11-az1",
        "hs-crypto-ep11-az2",
        "hs-crypto-ep11-az3",
        "hs-crypto-kmip",
        "hs-crypto-tke",
        "iam-svcs",
        "is",
        "kms",
        "messaging",
        "resource-controller",
        "support-center",
        "transit",
        "user-management",
        "vmware",
        "ntp"
      ], service.service_name)
    ]) == 0
  }
}

variable "cloud_service_by_crn" {
  description = "The list of cloud service CRNs used to create endpoint gateways. Use this list to identify services that are not supported by service name in the `cloud_services` variable. For a list of supported services, see [VPE-enabled services](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services). If `service_name` is not specified, the CRN is used to find the name. If `vpe_name` is not specified in the list, VPE names are created in the format `<prefix>-<vpc_name>-<service_name>`. The value that you specify for `vpc_name` must be known at Terraform plan time. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-vpe-gateway/tree/main/solutions/fully-configurable/DA-types.md#cloud_service_by_crn)."
  type = set(
    object({
      crn                          = string
      vpe_name                     = optional(string) # Full control on the VPE name. If not specified, the VPE name will be computed based on prefix, vpc name and service name.
      service_name                 = optional(string) # Name of the service used to compute the name of the VPE. If not specified, the service name will be obtained from the crn.
      allow_dns_resolution_binding = optional(bool, true)
    })
  )
  default = []
}

variable "service_endpoints" {
  description = "Service endpoints to use to create endpoint gateways. Can be `public`, or `private`."
  type        = string
  default     = "private"

  validation {
    error_message = "Service endpoints can only be `public` or `private`."
    condition     = contains(["public", "private"], var.service_endpoints)
  }
}

variable "reserved_ips" {
  description = "Map of existing reserved IP names and values. If you wish to create your reserved ips independently and not create new ones you can first run the `reserved-ips` submodule and then copy the output `reserved_ip_map` here. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-vpe-gateway/tree/main/solutions/fully-configurable/DA-types.md#reserved_ips)."
  type = object({
    name = optional(string) # reserved ip name
  })
  default = {}
}

##############################################################################
