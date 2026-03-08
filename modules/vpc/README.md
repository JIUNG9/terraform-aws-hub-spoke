# VPC Module

Creates an AWS VPC with public, private, and database subnets across 2 availability zones. Includes optional NAT Gateway and VPC Flow Logs.

## Usage

```hcl
module "vpc" {
  source = "github.com/junegu/terraform-aws-hub-spoke//modules/vpc"

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
| `name_prefix` | Computed name prefix for all resources |

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
