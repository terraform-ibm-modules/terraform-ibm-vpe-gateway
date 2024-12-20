##############################################################################
# Terraform Providers
##############################################################################

terraform {
  # Use "greater than or equal to" range in modules
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.58.0, <2.0.0"
    }
  }
  required_version = ">=1.3"
}

##############################################################################
