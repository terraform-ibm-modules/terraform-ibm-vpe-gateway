##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.9.0"
  # Use "greater than or equal to" range in modules
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.79.2, <2.0.0"
    }
  }
}

##############################################################################
