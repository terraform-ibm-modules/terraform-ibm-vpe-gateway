##############################################################################
# Terraform Providers
##############################################################################

terraform {
  # Use "greater than or equal to" range in modules
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.76.3"
    }
  }
  required_version = ">=1.9.0"
}

##############################################################################
