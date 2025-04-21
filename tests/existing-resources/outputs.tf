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
