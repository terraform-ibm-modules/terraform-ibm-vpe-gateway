##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3.0"
  # Pin to the lowest provider version of the range defined in the main module's version.tf to ensure lowest version still works
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # pin above lowest vesion, required for postgresql and IAM auth policy
      version = "1.54.0"
    }
    # The time provider is not actually required by the module itself, just this example, so OK to use ">=" here instead of locking into a version
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

##############################################################################
