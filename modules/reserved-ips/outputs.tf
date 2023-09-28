output "reserved_ips" {
  description = "The endpoint gateway reserved ips"
  value = {
    for reserved_ip in ibm_is_subnet_reserved_ip.ip :
    # Create object for each reservedIP
    reserved_ip.name => {
      address     = reserved_ip.address
      name        = reserved_ip.name
      reserved_ip = reserved_ip.reserved_ip
      subnet      = reserved_ip.subnet
      auto_delete = reserved_ip.auto_delete
    }
  }
}

output "endpoint_ip_list" {
  description = "The endpoint gateway reserved ips"
  value       = local.endpoint_ip_list
}
