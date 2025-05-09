// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const reservedIpExampleTerraformDir = "examples/reserved-ips"

func TestRunReservedIpExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "res-ips", reservedIpExampleTerraformDir)
	options.SkipTestTearDown = true
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
	// checking reserved_ips to exist
	outputs := terraform.OutputAll(options.Testing, options.TerraformOptions)
	expectedOutputs := []string{"reserved_ips"}
	_, outputErr := testhelper.ValidateTerraformOutputs(outputs, expectedOutputs...)
	assert.NoErrorf(t, outputErr, "Some outputs not found or nil")
	_, ok := outputs["reserved_ips"].(map[string]interface{})
	var outputErrMap error
	if !ok {
		outputErrMap = fmt.Errorf("Output: Failed to read value of key %s\n", "reserved_ips")
	}

	assert.NoErrorf(t, outputErr, "Some outputs not found or nil")
	assert.NoErrorf(t, outputErrMap, "Some outputs not having the expected structure")
	options.TestTearDown()
}

// TEST NOTE:
// This test will deploy all 30+ multitenant services in order to test that our current CRN mappings are correct
// for these service names.
// However there is an issue with the provider currently that prevents all 30+ VPEs to deploy at once, resulting in a
// "VPC Locked" error.
// In order to test all 30+ services, we will run this other test single-threaded (parallelism=1).
//
// IBM Terraform provider issue for this issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6224
func TestRunEveryMultiTenantExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "vpe-allmt", "examples/every-multi-tenant-svc")

	// need to do setup so that TerraformOptions is created
	options.TestSetup()

	// save the current parallelism value, we will reset to this value later
	currentParallelValue := options.TerraformOptions.Parallelism
	t.Logf("Terratest Parallelism currently set to %d, replacing with 1 for single-threaded apply", currentParallelValue)
	options.TerraformOptions.Parallelism = 1

	// after apply, set parallelism back to default to help quicken remaining steps
	options.PostApplyHook = func(options *testhelper.TestOptions) error {
		t.Logf("Terratest Parallelism will be switched back to %d from single-threaded", currentParallelValue)
		options.TerraformOptions.Parallelism = currentParallelValue
		return nil
	}

	// turn off test setup, already done
	options.SkipTestSetup = true

	// now do full test single-threaded
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored.")
	assert.NotNil(t, output, "Expected some output")
}
