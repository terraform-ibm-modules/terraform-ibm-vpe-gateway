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

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
  default     = "my-vpc-instance"
}

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
