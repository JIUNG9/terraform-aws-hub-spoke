# VPC Module

Creates an AWS VPC with public, private, and database subnets across 2 availability zones. Includes optional NAT Gateway and VPC Flow Logs.

## Usage

```hcl
module "vpc" {
  source = "github.com/JIUNG9/terraform-aws-hub-spoke//modules/vpc"

  organization = "myorg"
  project      = "platform"
  service      = "api"
  environment  = "prod"

  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets    = ["10.1.11.0/24", "10.1.12.0/24"]
  database_subnets   = ["10.1.21.0/24", "10.1.22.0/24"]
  enable_nat_gateway = true

  tags = {
    Team = "platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `organization` | Organization identifier used in naming | `string` | - | yes |
| `project` | Project or team group name | `string` | - | yes |
| `service` | Service name | `string` | - | yes |
| `environment` | Environment (prod, stage, dev, hub, shared) | `string` | - | yes |
| `region` | AWS region for naming convention | `string` | `"ap-northeast-2"` | no |
| `vpc_cidr` | CIDR block for the VPC | `string` | - | yes |
| `availability_zones` | List of AZs (minimum 2) | `list(string)` | - | yes |
| `public_subnets` | CIDR blocks for public subnets | `list(string)` | `[]` | no |
| `private_subnets` | CIDR blocks for private subnets | `list(string)` | `[]` | no |
| `database_subnets` | CIDR blocks for database subnets | `list(string)` | `[]` | no |
| `map_public_ip_on_launch` | Auto-assign public IPs in public subnets | `bool` | `false` | no |
| `create_igw` | Create an Internet Gateway | `bool` | `true` | no |
| `enable_nat_gateway` | Create a NAT Gateway | `bool` | `true` | no |
| `enable_vpc_endpoints` | Enable Gateway VPC endpoints (S3, DynamoDB) | `bool` | `false` | no |
| `gateway_endpoint_services` | List of Gateway endpoint services | `list(string)` | `["s3", "dynamodb"]` | no |
| `enable_interface_endpoints` | Enable Interface VPC endpoints | `bool` | `false` | no |
| `interface_endpoint_services` | List of Interface endpoint services | `list(string)` | `["ssm", "ssmmessages", "ec2messages"]` | no |
| `enable_flow_logs` | Enable VPC Flow Logs | `bool` | `false` | no |
| `flow_logs_retention_days` | Flow Logs retention in days | `number` | `30` | no |
| `tags` | Additional tags for all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC |
| `vpc_cidr_block` | CIDR block of the VPC |
| `vpc_arn` | ARN of the VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `public_subnet_cidrs` | List of public subnet CIDR blocks |
| `private_subnet_ids` | List of private subnet IDs |
| `private_subnet_cidrs` | List of private subnet CIDR blocks |
| `database_subnet_ids` | List of database subnet IDs |
| `database_subnet_cidrs` | List of database subnet CIDR blocks |
| `database_subnet_group_name` | Name of the DB subnet group |
| `public_route_table_id` | ID of the public route table |
| `private_route_table_id` | ID of the private route table |
| `database_route_table_id` | ID of the database route table |
| `internet_gateway_id` | ID of the Internet Gateway |
| `nat_gateway_id` | ID of the NAT Gateway |
| `nat_gateway_public_ip` | Public IP of the NAT Gateway |
| `gateway_endpoint_ids` | Map of Gateway VPC endpoint IDs |
| `interface_endpoint_ids` | Map of Interface VPC endpoint IDs |
| `name_prefix` | Computed name prefix for all resources |

## VPC Endpoints

The module supports two types of VPC endpoints:

**Gateway Endpoints** (free, enabled via `enable_vpc_endpoints`):
- S3 and DynamoDB by default
- Route-based, attached to private and database route tables
- No additional cost, no security group required

**Interface Endpoints** (~$7.30/mo each, enabled via `enable_interface_endpoints`):
- SSM, SSM Messages, and EC2 Messages by default (for Session Manager access)
- ENI-based, deployed into private subnets
- Dedicated security group allowing HTTPS (443) from VPC CIDR
- Customize the service list via `interface_endpoint_services`

```hcl
module "vpc" {
  source = "github.com/JIUNG9/terraform-aws-hub-spoke//modules/vpc"

  # ... other variables ...

  # Free — always enable in production
  enable_vpc_endpoints = true

  # ~$7.30/mo each — enable if you need SSM Session Manager
  enable_interface_endpoints  = true
  interface_endpoint_services = ["ssm", "ssmmessages", "ec2messages"]
}
```

## Architecture

```
VPC (10.x.0.0/16)
  |
  +-- Public Subnets (10.x.1.0/24, 10.x.2.0/24)
  |     |-- Internet Gateway
  |     +-- NAT Gateway (optional)
  |
  +-- Private Subnets (10.x.11.0/24, 10.x.12.0/24)
  |     +-- Route to NAT Gateway (if enabled)
  |
  +-- Database Subnets (10.x.21.0/24, 10.x.22.0/24)
        +-- Isolated (no internet route)
        +-- DB Subnet Group
```
