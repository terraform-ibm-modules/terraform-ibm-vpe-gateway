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
  default     = "sg-vpe"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = "geretain-test-resources"
}

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_name" {
  description = "Name of the VPC where the Endpoint Gateways will be created. This value is used to dynamically generate VPE names."
  type        = string
  default     = "my-vpc-instance"
}

variable "vpc_id" {
  description = "ID of the VPC where the Endpoint Gateways will be created"
  type        = string
  default     = null
}

variable "create_vpc" {
  description = "Create a VPC instance."
  type        = bool
  default     = true
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

variable "cloud_services" {
  description = "List of cloud services to create an endpoint gateway."
  type        = list(string)
  default     = ["kms", "cloud-object-storage"]

  validation {
    error_message = "Currently the only supported services are Key Protect (`kms`), Cloud Object Storage (`cloud-object-storage`), Container Registry (`container-registry`), and Hyper Protect Crypto Services (`hs-crypto`). Any other VPE services must be added using `cloud_service_by_crn`."
    condition = length(var.cloud_services) == 0 ? true : length([
      for service in var.cloud_services :
      service if !contains([
        "kms",
        "hs-crypto",
        "cloud-object-storage",
        "container-registry"
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

variable "service_endpoints" {
  description = "Service endpoints to use to create endpoint gateways. Can be `public`, or `private`."
  type        = string
  default     = "private"

  validation {
    error_message = "Service endpoints can only be `public` or `private`."
    condition     = contains(["public", "private"], var.service_endpoints)
  }
}

##############################################################################

##############################################################################
# Security Group Variables
##############################################################################
variable "security_group_rules" {
  description = "A list of security group rules to be added to the default vpc security group"
  type = list(
    object({
      name      = string
      direction = string
      remote    = string
      tcp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      udp = optional(
        object({
          port_max = optional(number)
          port_min = optional(number)
        })
      )
      icmp = optional(
        object({
          type = optional(number)
          code = optional(number)
        })
      )
    })
  )
  default = [{
    name      = "allow-all-inbound"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    }, {
    name      = "sgr-tcp"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    tcp = {
      port_min = 8080
      port_max = 8080
    }
    }, {
    name      = "sgr-udp"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    udp = {
      port_min = 805
      port_max = 807
    }
    }, {
    name      = "sgr-icmp"
    direction = "inbound"
    remote    = "0.0.0.0/0"
    icmp = {
      code = 20
      type = 30
    }
  }]
}

variable "add_ibm_cloud_internal_rules" {
  description = "Add IBM cloud Internal rules to the provided security group rules"
  type        = bool
  default     = false
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}
