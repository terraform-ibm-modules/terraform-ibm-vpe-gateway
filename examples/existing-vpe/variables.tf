variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  description = "The region where the VPC and services are deployed"
  type        = string
}

variable "prefix" {
  description = "The prefix to append to resource names"
  type        = string
}

variable "resource_group" {
  type        = string
  description = "An existing resource group name to use for this example, if unset a new resource group will be created"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "The ID of the existing VPC"
}

variable "vpc_name" {
  type        = string
  description = "The name of the existing VPC, used to compute VPE names"
}

variable "subnet_zone_list" {
  description = "List of subnets in the VPC where reserved IPs will be provisioned"
  type = list(object({
    name = string
    id   = string
    zone = string
    cidr = optional(string)
  }))
}

variable "service_name" {
  type        = string
  description = "The service name of the existing VPE gateway (e.g. \"kms\")"
}

variable "existing_vpe_name" {
  type        = string
  description = "The name of the existing VPE gateway (must match the actual gateway name)"
}

variable "existing_vpe_id" {
  type        = string
  description = "The ID of the existing VPE gateway to adopt"
}
