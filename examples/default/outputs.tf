output "vpe_endpoints" {
    description = "Vpe Service Endpoints"
    value = module.vpes.vpe_service_endpoints
}

output "vpe_ips" {
    description = "The endpoint gateway reserved ips"
    value = module.vpes.vpe_ips
}