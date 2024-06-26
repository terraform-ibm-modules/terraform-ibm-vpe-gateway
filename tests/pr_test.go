// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"reflect"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const advancedExampleTerraformDir = "examples/advanced"

const region = "us-south"

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		Region:       region,
		IgnoreUpdates: testhelper.Exemptions{ // Ignore for consistency check
			List: []string{
				"time_sleep.sleep_time",
			},
		},
		ResourceGroup: resourceGroup,
	})
	return options
}

// ValidateOutputMapSliceContent takes a map of Terraform output keys and values and it expects that the
// map contains a set of key => Slices couples
// It checks that the input map has length > 0 and for each key the related Slice is not empty
// If the value related to a key is not a slice it returns an error message
// The function returns a list of the output keys whose Slice has length 0
// and an error message that includes details about which keys were missing.
// If the input map is empty it returns only the related error message
func ValidateOutputMapOfSlicesContent(inputMap map[string]interface{}) ([]string, error) {
	var failedKeys []string
	var err error
	// Set up ANSI escape codes for blue and bold text
	blueBold := "\033[1;34m"
	reset := "\033[0m"

	// mapLen := len(inputMap)
	// fmt.Println("Len of inputMap is ", mapLen)
	if len(inputMap) == 0 {
		err = fmt.Errorf("Output: %s'The input map has zero elements'%s\n", blueBold, reset)
	} else {
		// going through the inputMap keys
		for k, v := range inputMap {
			if reflect.TypeOf(v).String() == "[]interface {}" {
				vArray := v.([]interface{})
				if len(vArray) == 0 {
					failedKeys = append(failedKeys, k)
					err = fmt.Errorf("Output: The keys %s'%s'%s have empty slices\n", blueBold, failedKeys, reset)
				}
			} else {
				failedKeys = append(failedKeys, k)
				err = fmt.Errorf("Output: The key %s'%s'%s value is not a slice\n", blueBold, k, reset)
				break
			}
		}
	}

	return failedKeys, err
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "vpe-adv", advancedExampleTerraformDir)
	options.SkipTestTearDown = true
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
	// checking vpe_ips to exist
	outputs := terraform.OutputAll(options.Testing, options.TerraformOptions)
	expectedOutputs := []string{"vpe_ips"}
	_, outputErr := testhelper.ValidateTerraformOutputs(outputs, expectedOutputs...)
	assert.NoErrorf(t, outputErr, "Some outputs not found or nil")
	// checking vpe_ips to contain a set on not empty slices as expected
	mapToValidate, ok := outputs["vpe_ips"].(map[string]interface{})
	var outputErrMap error
	if !ok {
		outputErrMap = fmt.Errorf("Output: Failed to read value of key %s\n", "vpe_ips")
	} else {
		_, outputErrMap = ValidateOutputMapOfSlicesContent(mapToValidate)
	}

	assert.NoErrorf(t, outputErr, "Some outputs not found or nil")
	assert.NoErrorf(t, outputErrMap, "Some outputs not having the expected structure")
	options.TestTearDown()
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "vpe-upgrade", advancedExampleTerraformDir)
	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestRunEveryMultiTenantExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "vpe-allmt", "examples/basic")
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
