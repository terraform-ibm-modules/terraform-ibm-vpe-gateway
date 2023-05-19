// Tests in this file are run in the PR pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const defaultExampleTerraformDir = "examples/default"

const region = "us-south"

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	cloudServices := []string{
		"kms",
		"hs-crypto",
		"cloud-object-storage",
		"account-management",
		"billing",
		"codeengine",
		"directlink",
		"dns-svcs",
		"enterprise",
		"globalcatalog",
		"global-search-tagging",
		"hyperp-dbaas-mongodb",
		"hyperp-dbaas-postgresql",
		"iam-svcs",
		"resource-controller",
		"transit",
		"user-management",
		"is",
	}

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"region":         region,
			"cloud_services": cloudServices,
		},
	})
	return options
}

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "vpe-default", defaultExampleTerraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Skip()
	t.Parallel()

	options := setupOptions(t, "vpe-upgrade", defaultExampleTerraformDir)
	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
