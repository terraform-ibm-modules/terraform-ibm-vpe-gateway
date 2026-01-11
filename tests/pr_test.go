// Tests in this file are run in the PR pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"reflect"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const advancedExampleTerraformDir = "examples/advanced"
const fullConfigSolutionDir = "solutions/fully-configurable"
const existingVpcTerraformDir = "tests/existing-resources"

const region = "us-south"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]any

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupMontrealOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		Region:       "ca-mon",
		IgnoreUpdates: testhelper.Exemptions{ // Ignore for consistency check
			List: []string{
				"time_sleep.sleep_time",
			},
		},
		ResourceGroup: resourceGroup,
	})
	return options
}

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

// sets up options for solutions through schematics
func setupSolutionSchematicOptions(t *testing.T, prefix string, dir string) *testschematic.TestSchematicOptions {

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		TarIncludePatterns: []string{
			"*.tf",
			"modules/reserved-ips/*.tf",
			dir + "/*.tf",
		},
		TemplateFolder:         dir,
		Tags:                   []string{"test-schematic"},
		Prefix:                 prefix,
		Region:                 region,
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
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

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "vpe-basic", "examples/basic")
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored.")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunMontrealExample(t *testing.T) {
	t.Parallel()

	options := setupMontrealOptions(t, "vpe-ca-mon", "examples/montreal-monitoring")
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored.")
	assert.NotNil(t, output, "Expected some output")
}

// helper function to set up inputs for full config solution test, will help keep it consistent
// between normal and upgrade tests
func getFullConfigSolutionTestVariables(mainOptions *testschematic.TestSchematicOptions, existingOptions *testhelper.TestOptions) []testschematic.TestSchematicTerraformVar {
	// try to cover some variety of use cases
	testCloudSvcList := []map[string]any{
		{"service_name": "is"},
		{"service_name": "kms", "dns_resolution_binding_mode": "primary"},
		{"service_name": "cloud-object-storage", "vpe_name": mainOptions.Prefix + "-cos"},
	}

	// use our perm postgres for this
	testCrnList := []map[string]any{
		{"crn": permanentResources["postgresqlPITRCrn"], "service_name": "pg"}, // had to shorten the name!
	}

	vars := []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: mainOptions.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: region, DataType: "string"},
		{Name: "prefix", Value: mainOptions.Prefix, DataType: "string"},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "vpc_name", Value: existingOptions.LastTestTerraformOutputs["vpc_name"], DataType: "string"},
		{Name: "subnet_ids", Value: existingOptions.LastTestTerraformOutputs["subnet_ids"], DataType: "list(string)"},
		{Name: "cloud_services", Value: testCloudSvcList, DataType: "set(object)"},
		{Name: "cloud_service_by_crn", Value: testCrnList, DataType: "set(object)"},
	}

	return vars
}

func TestRunFullConfigSolutionSchematics(t *testing.T) {

	// set up the options for existing resource deployment
	// needed by solution
	existingResourceOptions := setupOptions(t, "vpe-full", existingVpcTerraformDir)
	// Creates temp dirs and runs InitAndApply for existing resources
	// outputs will be in options after apply
	existingResourceOptions.SkipTestTearDown = true
	_, existDeployErr := existingResourceOptions.RunTest()
	defer existingResourceOptions.TestTearDown() // public function ignores skip above

	// immediately fail and exit test if existing deployment failed (tear down is in a defer)
	require.NoError(t, existDeployErr, "error creating needed existing VPC resources")

	// start main schematics test
	options := setupSolutionSchematicOptions(t, "vpe-full", fullConfigSolutionDir)
	options.TerraformVars = getFullConfigSolutionTestVariables(options, existingResourceOptions)

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")

}

func TestRunFullConfigSolutionUpgradeSchematics(t *testing.T) {

	// set up the options for existing resource deployment
	// needed by solution
	existingResourceOptions := setupOptions(t, "vpe-fcupg", existingVpcTerraformDir)
	// Creates temp dirs and runs InitAndApply for existing resources
	// outputs will be in options after apply
	existingResourceOptions.SkipTestTearDown = true
	_, existDeployErr := existingResourceOptions.RunTest()
	defer existingResourceOptions.TestTearDown() // public function ignores skip above

	// immediately fail and exit test if existing deployment failed (tear down is in a defer)
	require.NoError(t, existDeployErr, "error creating needed existing VPC resources")

	// start main schematics test
	options := setupSolutionSchematicOptions(t, "vpe-fcupg", fullConfigSolutionDir)
	options.TerraformVars = getFullConfigSolutionTestVariables(options, existingResourceOptions)

	err := options.RunSchematicUpgradeTest()
	assert.Nil(t, err, "This should not have errored")

}
