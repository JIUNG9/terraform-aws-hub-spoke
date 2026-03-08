# Complete Example: Hub + 2 Spoke Accounts

This example deploys a full hub-spoke network architecture with:

- **Hub account**: Transit Gateway + shared services VPC (`10.0.0.0/16`)
- **Production spoke**: VPC (`10.1.0.0/16`) attached to TGW prod route table
- **Staging spoke**: VPC (`10.50.0.0/16`) attached to TGW stage route table

Route table isolation ensures production and staging cannot communicate directly -- all traffic flows through the hub.

## Prerequisites

1. Three AWS accounts (hub, prod, stage)
2. Cross-account IAM role `TerraformCrossAccountRole` in each spoke account
3. AWS credentials configured for the hub account

## Usage

```bash
# Initialize
terraform init

# Create a terraform.tfvars file
cat > terraform.tfvars <<EOF
organization     = "myorg"
region           = "ap-northeast-2"
prod_account_id  = "111111111111"
stage_account_id = "222222222222"
EOF

# Plan
terraform plan

# Apply
terraform apply
```

## Network Topology After Apply

```
Hub VPC (10.0.0.0/16)
  |
  +-- Transit Gateway (ASN 64512)
        |
        +-- [prod RT] --> Prod VPC (10.1.0.0/16)
        |
        +-- [stage RT] --> Stage VPC (10.50.0.0/16)

Routing:
  Hub   <--> Prod   (allowed)
  Hub   <--> Stage  (allowed)
  Prod  <--> Stage  (blocked by RT isolation)
```

## Clean Up

```bash
terraform destroy
```
