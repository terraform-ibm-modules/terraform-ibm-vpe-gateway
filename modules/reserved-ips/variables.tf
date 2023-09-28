##############################################################################
# VPC Variables
##############################################################################
variable "region" {
  description = "The region where VPC and services are deployed"
  type        = string
  default     = "us-south"
}

variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
  default     = "vpe"
}

variable "vpc_name" {
  description = "Name of the VPC where the Endpoint Gateways will be created. This value is used to dynamically generate VPE names."
  type        = string
  default     = "vpc"
}

##############################################################################
# SUBNET Variables
##############################################################################

variable "subnet_zone_list" {
  description = "List of subnets in the VPC where gateways and reserved IPs will be provisioned. This value is intended to use the `subnet_zone_list` output from the Landing Zone VPC Subnet Module (https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc) or from templates using that module for subnet creation."
  type = list(
    object({
      name = string
      id   = string
      zone = optional(string)
      cidr = optional(string)
    })
  )
  default = []
}

##############################################################################
# VPE Variables
##############################################################################

variable "vpe_names" {
  description = "A Map to specify custom names for endpoint gateways whose keys are services and values are names to use for that service's endpoint gateway. Each name will be prefixed with prefix value for isolated testing purposes."
  type        = map(string)
  default     = {}
}

variable "cloud_service_by_crn" {
  description = "List of cloud service CRNs. Each CRN will have a unique endpoint gateways created. For a list of supported services, see the docs [here](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services)."
  type = list(
    object({
      name = string # service name
      crn  = string # service crn
    })
  )
  default = []
}

variable "cloud_services" {
  description = "List of cloud services to create an endpoint gateway."
  type        = list(string)
  default     = ["kms", "cloud-object-storage"]

  validation {
    error_message = "Currently the service you're trying to add is not supported. Any other VPE services must be added using `cloud_service_by_crn`."
    condition = length(var.cloud_services) == 0 ? true : length([
      for service in var.cloud_services :
      service if !contains([
        "account-management",
        "billing",
        "cloud-object-storage",
        "codeengine",
        "container-registry",
        "directlink",
        "dns-svcs",
        "enterprise",
        "global-search-tagging",
        "globalcatalog",
        "hs-crypto",
        "hyperp-dbaas-mongodb",
        "hyperp-dbaas-postgresql",
        "iam-svcs",
        "is",
        "kms",
        "resource-controller",
        "transit",
        "user-management",
      ], service)
    ]) == 0
  }
}

variable "reserved_ips" {
  description = "Reserved IPs to attach to attach to Endpoint Gateways."
  type        = map(map(string))
  default     = null
}
