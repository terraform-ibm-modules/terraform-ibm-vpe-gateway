// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const nonDefaultExampleTerraformDir = "examples/non-default"

func TestRunNonDefaultExample(t *testing.T) {
	t.Parallel()

	cloudServices := []string{
		"account-management",
		"billing",
		"cloud-object-storage",
		"codeengine",
		"directlink",
		"dns-svcs",
		"enterprise",
		"global-search-tagging",
		"globalcatalog",
		"hs-crypto",
		"hyperp-dbaas-mongodb",
		"hyperp-dbaas-postgresql",
		"iam-svcs",
		"is",
		"kms",
		"resource-controller",
		"transit",
		"user-management",
	}

	vpeNames := map[string]string{
		"cloud-object-storage": "custom-cos-name",
		"kms":                  "custom-kms-name",
		"postgresql":           "custom-postgres-name",
	}

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: nonDefaultExampleTerraformDir,
		Prefix:       "vpe-non-default",
		IgnoreUpdates: testhelper.Exemptions{ // Ignore for consistency check
			List: []string{
				"time_sleep.sleep_time",
			},
		},
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"region":         region,
			"cloud_services": cloudServices,
			"vpe_names":      vpeNames,
		},
	})
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
