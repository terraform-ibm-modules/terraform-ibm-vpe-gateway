##############################################################################
# Terraform Providers
##############################################################################

terraform {
  # Use "greater than or equal to" range in modules
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.61.0, <2.0.0"
    }
  }
  required_version = ">=1.3, <1.6.0"
}

##############################################################################
