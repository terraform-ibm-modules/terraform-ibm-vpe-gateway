##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3.0"
  # Ensure that there is always 1 example locked into the lowest provider version of the range defined in the main
  # module's version.tf (basic or default), and 1 example that will always use the latest provider version.
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # pin above lowest vesion, required for postgresql and IAM auth policy
      version = ">=1.61.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

##############################################################################
