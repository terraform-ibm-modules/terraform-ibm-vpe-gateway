##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3.0, <1.6.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # pin above lowest vesion, required for postgresql and IAM auth policy
      version = ">=1.61.0, <2.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

##############################################################################
