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

variable "security_group_ids" {
  description = "List of security group ids to attach to each endpoint gateway."
  type        = list(string)
  default     = null
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
