variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

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

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_name" {
  description = "Name of the VPC where the Endpoint Gateways will be created. This value is used to dynamically generate VPE names. It is also used to create a VPC when the vpc_id input is set to null."
  type        = string
  default     = "vpc-instance"
}

variable "vpc_id" {
  description = "ID of the VPC where the Endpoint Gateways will be created. Creates a VPC if set to null."
  type        = string
  default     = null
}

##############################################################################

##############################################################################
# VPE Variables
##############################################################################

variable "subnet_zone_list" {
  description = "List of subnets in the VPC where gateways and reserved IPs will be provisioned. This value is intended to use the `subnet_zone_list` output from the ICSE VPC Subnet Module (https://github.com/Cloud-Schematics/vpc-subnet-module) or from templates using that module for subnet creation."
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

variable "security_group_ids" {
  description = "List of security group ids to attach to each endpoint gateway."
  type        = list(string)
  default     = null
}

variable "cloud_services" {
  description = "List of cloud services to create an endpoint gateway."
  type        = list(string)
  default     = ["kms", "cloud-object-storage"]
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

variable "service_endpoints" {
  description = "Service endpoints to use to create endpoint gateways. Can be `public`, or `private`."
  type        = string
  default     = "private"

  validation {
    error_message = "Service endpoints can only be `public` or `private`."
    condition     = contains(["public", "private"], var.service_endpoints)
  }
}

variable "vpe_names" {
  description = "A Map to specify custom names for endpoint gateways whose keys are services and values are names to use for that service's endpoint gateway."
  type        = map(string)
  default     = {}
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

##############################################################################
