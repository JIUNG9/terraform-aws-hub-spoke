# Transit Gateway Module

Creates an AWS Transit Gateway with environment-isolated route tables for hub-spoke network architecture. Optionally shares the TGW across accounts via AWS RAM.

## Usage

```hcl
module "tgw" {
  source = "github.com/JIUNG9/terraform-aws-hub-spoke//modules/tgw"

  organization = "myorg"
  project      = "platform"
  environment  = "hub"

  amazon_side_asn              = 64512
  auto_accept_shared_attachments = true
  environment_route_tables     = ["prod", "stage", "dev"]

  # Cross-account sharing
  enable_ram_sharing = true
  ram_principal_arns = [
    "111111111111",  # prod account
    "222222222222",  # stage account
    "333333333333",  # dev account
  ]

  tags = {
    Team = "platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `organization` | Organization identifier | `string` | - | yes |
| `project` | Project or team group name | `string` | - | yes |
| `environment` | Environment name for the hub | `string` | `"hub"` | no |
| `region` | AWS region for naming | `string` | `"ap-northeast-2"` | no |
| `amazon_side_asn` | Private ASN for the TGW | `number` | `64512` | no |
| `auto_accept_shared_attachments` | Auto-accept cross-account attachments | `bool` | `true` | no |
| `environment_route_tables` | Environment names for isolated route tables | `list(string)` | `["prod", "stage", "dev"]` | no |
| `enable_ram_sharing` | Share TGW via AWS RAM | `bool` | `false` | no |
| `allow_external_principals` | Allow external principals in RAM share | `bool` | `false` | no |
| `ram_principal_arns` | Account IDs or Org ARNs to share with | `list(string)` | `[]` | no |
| `tags` | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `transit_gateway_id` | ID of the Transit Gateway |
| `transit_gateway_arn` | ARN of the Transit Gateway |
| `transit_gateway_owner_id` | Owner account ID |
| `route_table_ids` | Map of environment name to route table ID |
| `hub_route_table_id` | ID of the hub route table |
| `ram_resource_share_arn` | ARN of the RAM share (null if disabled) |
| `name_prefix` | Computed name prefix |

## Route Table Isolation

The module creates one TGW route table per environment. This enables network isolation:

- **prod** route table: holds the hub's route only (propagated from the hub attachment)
- **stage** route table: holds the hub's route only
- **dev** route table: holds the hub's route only
- **hub** route table (`hub_route_table_id`): holds the route of every spoke, propagated from each spoke attachment

A spoke attachment is associated with its environment table and propagates into the hub table. The hub attachment is associated with the hub table and propagates into every environment table. A spoke can therefore reach the hub and the hub can reach every spoke, but a prod spoke has no route to a stage spoke.
