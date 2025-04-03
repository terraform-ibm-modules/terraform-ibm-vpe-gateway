# Deploy Service Level Tenant for STS log routing to IBM Cloud Logs

This architecture deploys service level tenant for log routing which point to a cloud logs instance. Optionally it also deploy a service level default tenant for existing mezmo STS instance.

## Before you begin

* You must have a Cloud Logs instance.

**NOTE:** In order for logs to flow, you must have the STS agent running in a RedHat OpenShift or Kubernetes cluster.

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
