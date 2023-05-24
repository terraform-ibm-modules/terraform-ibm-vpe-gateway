moved {
  from = ibm_is_virtual_endpoint_gateway.vpe[1]
  to   = ibm_is_virtual_endpoint_gateway.vpe["vpc-instance-cloud-object-storage"]
}

moved {
  from = ibm_is_virtual_endpoint_gateway.vpe[0]
  to   = ibm_is_virtual_endpoint_gateway.vpe["vpc-instance-kms"]
}
