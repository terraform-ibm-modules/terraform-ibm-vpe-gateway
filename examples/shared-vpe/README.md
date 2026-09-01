# Shared pre-existing VPE gateway example (Owner-Consumer Pattern)

This example demonstrates the **Shared VPE Gateway topology**, which is a common real-world pattern where multiple consumer workloads (like independent IKS/ROKS clusters) share a single pre-existing Virtual Private Endpoint (VPE) Gateway within the same VPC.

By sharing a single gateway (e.g., for Key Protect, Cloud Object Storage, or IBM Backup & Recovery Service), you avoid redundant gateway provisioning and licensing costs, while allowing each cluster to manage its own subnet bindings and reserved IPs.

The example is split into two independent workspaces to mimic a real-world multi-workspace configuration:

## Directory Structure

* [`owner/`](./owner): Representing **Cluster A** (the owner stack), which provisions the VPC, subnets, and the shared VPE Gateway with an initial subnet binding.
* [`consumer/`](./consumer): Representing **Cluster B** (the consumer stack), which dynamically queries the existing VPE and VPC, automatically filters out already-bound subnets, and attaches new consumer reserved IPs to that same gateway.

---

## Developer Workflow

### Step 1: Deploy the Owner Stack
Go to the [`owner/`](./owner) directory and apply the configuration. This creates the VPC, subnets, and the shared VPE Gateway bound to the first subnet.

```bash
cd owner
terraform init
terraform apply
```

Note down the outputs, specifically:
- `vpe_ids`: The ID of the KMS gateway.
- `crn`: The CRN of the KMS gateway.

### Step 2: Deploy the Consumer Stack
Go to the [`consumer/`](./consumer) directory and configure your `terraform.tfvars` with the outputs from the owner run:

```hcl
region            = "us-south"
prefix            = "vpe-shared-consumer"
existing_vpe_name = "vpe-shared-owner-vpc-kms"                         # Replace with actual owner gateway name
existing_vpe_id   = "r006-7eb19f34-ec16-4418-85eb-834f9deef78a"         # Replace with actual owner gateway ID
service_name      = "kms"
```

Apply the consumer configuration:

```bash
cd ../consumer
terraform init
terraform apply
```

The consumer stack will:
1. Dynamically retrieve the existing VPE and VPC details.
2. Filter out `subnet-a` because the owner already bound a reserved IP to it (avoiding API errors since only 1 IP per zone is permitted).
3. Securely create and bind new consumer reserved IPs in `subnet-b` and `subnet-c` to the pre-existing gateway.

### Step 3: Verify Lifetime Independence
To verify that the pre-existing gateway is unaffected when the consumer is decommissioned, run a destroy inside the consumer folder:

```bash
terraform destroy
```

This will delete **only** the consumer-managed reserved IPs and attachments in `subnet-b` and `subnet-c`. The shared VPE Gateway itself and the owner's binding in `subnet-a` remain fully functional and untouched!
