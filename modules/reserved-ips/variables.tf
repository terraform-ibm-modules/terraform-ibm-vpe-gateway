##############################################################################
# VPC Variables
##############################################################################

variable "prefix" {
  description = "The prefix that you would like to append to your resources. Value is only used if no value is passed for the `vpe_name` option in the `reserved_ip_cloud_services` input variable."
  type        = string
  default     = "vpe"
}

variable "vpc_name" {
  description = "Name of the VPC that will be used in naming the newly created reserved ip(s). Value is only used if no value is passed for the `vpe_name` option in the `reserved_ip_cloud_services` input variable."
  type        = string
  default     = "vpc"
}

##############################################################################
# SUBNET Variables
##############################################################################

variable "subnet_zone_list" {
  description = "List of subnets in the VPC where reserved IPs will be provisioned. `name`, and `zone` are used in the naming convention of the reserved ip's which are then assigned to the subnet `id`. This value is intended to use the `subnet_zone_list` output from the Landing Zone VPC Subnet Module (https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc) or from templates using that module for subnet creation."
  type = list(
    object({
      name = string
      id   = string
      zone = optional(string)
    })
  )
  default = []
}


##############################################################################
# VPE Variables
##############################################################################

variable "region" {
  description = "The region to be used in the reserved ip naming convention."
  type        = string
  default     = "us-south"
}

variable "reserved_ip_cloud_services" {
  description = "List of cloud services to create reserved ips for. The keys are the service names, the values (all optional) give some level of control on the created VPEs."
  type = set(object({
    service_name = string
    vpe_name     = optional(string),
  }))
  default = []
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

variable "endpoint_ip_list" {
  description = "List of IPs to create. Each object contains an ip name and subnet id"
  type = list(
    object({
      ip_name   = string # reserved ip name
      subnet_id = string # subnet id
      name      = string # ip name
    })
  )
  default = []
}

variable "reserved_ips" {
  description = "Map of existing reserved IP names and values. Leave this value as default if you want to create new reserved ips, this value is used in the main module in which a user passes their existing reserved ips created here so as to not attempt to recreate them."
  type = object({
    name = optional(string) # reserved ip name
  })
  default = {}
}
