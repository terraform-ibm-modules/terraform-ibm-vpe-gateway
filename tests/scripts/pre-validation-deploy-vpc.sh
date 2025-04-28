#! /bin/bash

############################################################################################################
## This script is used by the catalog pipeline to deploy the OCP cluster and Observability instances,
## which are the prerequisites for the Observability Agents DA.
############################################################################################################

set -e

DA_DIR="solutions/fully-configurable"
TERRAFORM_SOURCE_DIR="tests/existing-resources"
JSON_FILE="${DA_DIR}/catalogValidationValues.json"
REGION="us-south"
TF_VARS_FILE="terraform.tfvars"

(
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning prerequisite VPC .."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "region=\"${REGION}\""
    echo "prefix=\"vpe-cat-$(openssl rand -hex 2)\""
  } >> ${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  region_var_name="region"
  resource_group_var_name="existing_resource_group_name"
  resource_group_value=$(terraform output -state=terraform.tfstate -raw resource_group_name)
  vpc_name_var_name="vpc_name"
  vpc_name_value=$(terraform output -state=terraform.tfstate -raw vpc_name)
  subnet_ids_var_name="subnet_ids"
  subnet_ids_value=$(terraform output -state=terraform.tfstate -json subnet_ids)
  cloud_services_var_name="cloud_services"
  cloud_services_value='[{"service_name": "kms"}]'

  echo "Appending '${vpc_name_var_name}' and '${region_var_name}' input variable values to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg region_var_name "${region_var_name}" \
        --arg region_var_value "${REGION}" \
        --arg resource_group_var_name "${resource_group_var_name}" \
        --arg resource_group_value "${resource_group_value}" \
        --arg vpc_name_var_name "${vpc_name_var_name}" \
        --arg vpc_name_value "${vpc_name_value}" \
        --arg subnet_ids_var_name "${subnet_ids_var_name}" \
        --argjson subnet_ids_value "${subnet_ids_value}" \
        --arg cloud_services_var_name "${cloud_services_var_name}" \
        --argjson cloud_services_value "${cloud_services_value}" \
        '. + {($region_var_name): $region_var_value, ($resource_group_var_name): $resource_group_value, ($vpc_name_var_name): $vpc_name_value, ($subnet_ids_var_name): $subnet_ids_value, ($cloud_services_var_name): $cloud_services_value}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
