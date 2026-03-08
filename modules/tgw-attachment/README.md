# Transit Gateway Attachment Module

Attaches a spoke VPC to a Transit Gateway, associates it with the correct environment route table, and propagates routes. Optionally adds return routes in the VPC route tables.

## Usage

```hcl
module "prod_attachment" {
  source = "github.com/junegu/terraform-aws-hub-spoke//modules/tgw-attachment"

  organization = "myorg"
  project      = "commerce"
  service      = "api"
  environment  = "prod"

  transit_gateway_id = module.tgw.transit_gateway_id
  vpc_id             = module.prod_vpc.vpc_id
  subnet_ids         = module.prod_vpc.private_subnet_ids

  # Associate with prod route table
  route_table_id = module.tgw.route_table_ids["prod"]

  # Propagate routes to prod RT and hub RT so both can reach this VPC
  propagate_to_route_table_ids = [
    module.tgw.route_table_ids["prod"],
  ]

  # Add TGW route in VPC private/database route tables
  vpc_route_table_ids  = [
    module.prod_vpc.private_route_table_id,
    module.prod_vpc.database_route_table_id,
  ]
  tgw_destination_cidr = "10.0.0.0/8"

  tags = {
    Team = "commerce"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `organization` | Organization identifier | `string` | - | yes |
| `project` | Project or team group name | `string` | - | yes |
| `service` | Service name | `string` | - | yes |
| `environment` | Environment name | `string` | - | yes |
| `region` | AWS region for naming | `string` | `"ap-northeast-2"` | no |
| `transit_gateway_id` | ID of the Transit Gateway | `string` | - | yes |
| `vpc_id` | VPC ID to attach | `string` | - | yes |
| `subnet_ids` | Subnet IDs for TGW attachment ENIs | `list(string)` | - | yes |
| `route_table_id` | TGW route table to associate with | `string` | - | yes |
| `propagate_to_route_table_ids` | TGW route tables to propagate routes to | `list(string)` | `[]` | no |
| `vpc_route_table_ids` | VPC route tables to add TGW return routes to | `list(string)` | `[]` | no |
| `tgw_destination_cidr` | Destination CIDR for VPC TGW routes | `string` | `"10.0.0.0/8"` | no |
| `tags` | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `transit_gateway_attachment_id` | ID of the TGW VPC attachment |
| `transit_gateway_attachment_vpc_owner_id` | VPC owner account ID |
| `route_table_association_id` | ID of the route table association |
| `name_prefix` | Computed name prefix |

## How It Works

1. **Attachment**: Creates a TGW VPC attachment using the specified private subnets
2. **Association**: Associates the attachment with the environment-specific TGW route table (e.g., prod RT)
3. **Propagation**: Propagates the VPC's CIDR to specified TGW route tables so other VPCs can reach it
4. **VPC Routes**: Adds routes in VPC route tables pointing `10.0.0.0/8` (or custom CIDR) to the TGW
