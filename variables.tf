##############################################################################
# VPC Variables
##############################################################################

variable "region" {
  description = "The region where VPC and services are deployed"
  type        = string
  default     = "us-south"
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources. Value is only used if no value is passed for the `vpe_name` option in the `cloud_services` input variable."
  type        = string
  default     = "vpe"
}

variable "vpc_name" {
  description = "Name of the VPC where the Endpoint Gateways will be created. This value is used to dynamically generate VPE names. Value is only used if no value is passed for the `vpe_name` option in the `cloud_services` input variable."
  type        = string
  default     = "vpc"
}

variable "vpc_id" {
  description = "ID of the VPC where the Endpoint Gateways will be created"
  type        = string
  default     = null
}

variable "subnet_zone_list" {
  description = "List of subnets in the VPC where gateways and reserved IPs will be provisioned. This value is intended to use the `subnet_zone_list` output from the Landing Zone VPC Subnet Module (https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc) or from templates using that module for subnet creation."
  type = list(
    object({
      name = string
      id   = string
      zone = string
      cidr = optional(string)
    })
  )
  default = []
}

##############################################################################

##############################################################################
# VPE Variables
##############################################################################

variable "resource_group_id" {
  description = "ID of the resource group where endpoint gateways will be provisioned"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group ids to attach to each endpoint gateway."
  type        = list(string)
  default     = null
}


variable "cloud_services" {
  description = "List of cloud services to create an endpoint gateway. The keys are the service names, the values (all optional) give some level of control on the created VPEs."
  type = set(object({
    service_name                 = string
    vpe_name                     = optional(string), # Full control on the VPE name. If not specified, the VPE name will be computed based on prefix, vpc name and service name.
    allow_dns_resolution_binding = optional(bool, false)
  }))
  default = []
  validation {
    error_message = "Currently the service you're trying to add is not supported. Any other VPE services must be added using `cloud_service_by_crn`."
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
  description = "List of cloud service CRNs. The keys are the CRN. The values (all optional) give some level of control on the created VPEs. Each CRN will have a unique endpoint gateways created. For a list of supported services, see the docs [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services)."
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
  description = "Map of existing reserved IP names and values. If you wish to create your reserved ips independently and not create new ones you can first run the `reserved-ips` submodule and then copy the output `reserved_ip_map` here."
  type = object({
    name = optional(string) # endpoint gateway IP ID
  })
  default = {}
}

##############################################################################
