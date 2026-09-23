variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The region to deploy resources"
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "The prefix to append to resources"
  default     = "vpe"
}

variable "existing_vpc_name" {
  type        = string
  description = "The name of the existing VPC"
}

variable "subnet_zone_list" {
  description = "List of subnets to attach reserved IPs to when adopting an existing gateway."
  type = list(object({
    name = string
    id   = string
    zone = string
  }))
  default = []
}

variable "cloud_services" {
  description = "The list of cloud services to adopt. Set existing_vpe_id and vpe_name to adopt an already-existing gateway."
  type = set(object({
    service_name                = string
    vpe_name                    = optional(string)
    dns_resolution_binding_mode = optional(string, "disabled")
    existing_vpe_id             = optional(string)
  }))
  default = []
}

variable "cloud_service_by_crn" {
  description = "The list of cloud service CRNs used to create endpoint gateways. Use this list to identify services that are not supported by service name in the `cloud_services` variable. For a list of supported services, see [VPE-enabled services](https://cloud.ibm.com/docs/vpc?topic=vpc-vpe-supported-services). If `service_name` is not specified, the CRN is used to find the name. If `vpe_name` is not specified in the list, VPE names are created in the format `<prefix>-<vpc_name>-<service_name>`. The value that you specify for `vpc_name` must be known at Terraform plan time."
  type = set(object({
    crn                         = string
    vpe_name                    = optional(string)
    service_name                = optional(string)
    dns_resolution_binding_mode = optional(string, "primary")
    existing_vpe_id             = optional(string)
  }))
  default = []
}
