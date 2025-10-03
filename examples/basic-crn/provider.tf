provider "ibm" {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.region
  private_endpoint_type = "vpe"
}

provider "ibm" {
  alias                 = "montreal"
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = "ca-mon"
  private_endpoint_type = "vpe"
}
