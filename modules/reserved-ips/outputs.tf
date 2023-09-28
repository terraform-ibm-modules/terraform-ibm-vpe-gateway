output "reserved-ips" {
  description = "The endpoint gateway reserved ips"
  value       = { 
       for reserved-ip in ibm_is_subnet_reserved_ip.ip: 
       # Create object for each reservedIP
          reserved-ip.name => {
              address = reserved-ip.address
              name = reserved-ip.name
              reserved_ip  = reserved-ip.reserved_ip 
              subnet       = reserved-ip.subnet
              auto_delete  = reserved-ip.auto_delete
          }
    }
}

output "endpoint_ip_list" {
  description = "The endpoint gateway reserved ips"
  value       = local.endpoint_ip_list
}
