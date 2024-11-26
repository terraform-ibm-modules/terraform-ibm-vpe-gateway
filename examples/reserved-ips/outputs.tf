output "crn" {
  description = "The CRN of the endpoint gateway"
  value       = module.vpes.crn
}

output "reserved_ips" {
  description = "The map of reserved ips created in the example"
  value       = module.ips.reserved_ip_map
}

output "endpoint_ip_list" {
  description = "The endpoint ip list created in the example"
  value       = module.ips.endpoint_ip_list
}

output "subnet_zone_list" {
  description = "The subnet zone list created in the example"
  value       = var.vpc_id != null ? var.subnet_zone_list : module.vpc[0].subnet_zone_list
}
