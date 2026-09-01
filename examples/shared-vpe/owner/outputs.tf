output "vpc_name" {
  description = "Name of the VPC"
  value       = module.vpc.vpc_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_zone_list" {
  description = "A list containing subnet IDs and subnet zones"
  value       = module.vpc.subnet_zone_list
}

output "vpe_ips" {
  description = "The endpoint gateway reserved ips"
  value       = module.vpes_owner.vpe_ips
}

output "crn" {
  description = "The CRN of the endpoint gateway"
  value       = module.vpes_owner.crn
}

output "vpe_ids" {
  description = "A map of endpoint gateway names to their IDs"
  value       = module.vpes_owner.vpe_ids
}
