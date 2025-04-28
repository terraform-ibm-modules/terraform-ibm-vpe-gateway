##############################################################################
# Terraform Providers
##############################################################################

terraform {
  # Use "greater than or equal to" range in modules
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.77.1"
    }
  }
  required_version = ">=1.9.0"
}

##############################################################################
