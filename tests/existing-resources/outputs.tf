output "vpc_name" {
  description = "Name of VPC created"
  value       = module.vpc.vpc_name
}

output "vpc_id" {
  description = "ID of VPC created"
  value       = module.vpc.vpc_id
}

output "subnet_zone_list" {
  description = "A list containing subnet IDs and subnet zones"
  value       = module.vpc.subnet_zone_list
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = module.vpc.subnet_ids
}

output "resource_group_id" {
  description = "Resource Group ID of resources"
  value       = module.resource_group.resource_group_id
}

output "resource_group_name" {
  description = "Resource Group Name of resources"
  value       = module.resource_group.resource_group_name
}

output "vpe_crn" {
  description = "CRN of the created VPE gateway"
  value       = var.create_vpe ? module.vpe[0].crn : null
}

output "vpe_ips" {
  description = "Reserved IPs of the VPE gateway"
  value       = var.create_vpe ? module.vpe[0].vpe_ips : null
}

output "vpe_gateway_ids" {
  description = "Map of gateway name to gateway ID"
  value       = var.create_vpe ? module.vpe[0].gateway_ids : null
}

output "unbound_subnet_zone_list" {
  description = "Subnets not bound to the VPE gateway"
  value       = var.create_vpe ? slice(module.vpc.subnet_zone_list, 1, length(module.vpc.subnet_zone_list)) : null
}
