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
  default     = "vpe-shared-consumer"
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
  nullable    = false
}

variable "access_tags" {
  type        = list(string)
  description = "Optional list of access management tags to be added to created resources"
  default     = []
  nullable    = false
}

variable "existing_vpe_name" {
  type        = string
  description = "The name of the pre-existing VPE Gateway to adopt"
}

variable "existing_vpe_id" {
  type        = string
  description = "The ID of the pre-existing VPE Gateway to adopt"
}

variable "service_name" {
  type        = string
  description = "The service name of the pre-existing VPE Gateway (e.g. kms, cloud-object-storage)"
  default     = "kms"
}
