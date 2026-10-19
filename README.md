# terraform-aws-hub-spoke

[![CI](https://github.com/JIUNG9/terraform-aws-hub-spoke/actions/workflows/ci.yml/badge.svg)](https://github.com/JIUNG9/terraform-aws-hub-spoke/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Terraform modules for an AWS multi-account hub-spoke network on Transit Gateway: one hub account, isolated prod/stage/dev spokes, routing that keeps environments apart.

This is a reference implementation of a pattern I ran in production on a 5-account AWS estate. It's small on purpose (three modules, two examples, a `terraform test` suite) so you can read the whole thing and adapt it, rather than a general-purpose module to depend on. If you want a maintained building block, `terraform-aws-modules/vpc` and `terraform-aws-modules/transit-gateway` are the usual choice; this repo shows how the pieces fit for hub-spoke isolation.

## Architecture

```
                         +-------------------------------+
                         |       Hub Account             |
                         |                               |
                         |   +---------------------+     |
                         |   |   Transit Gateway    |     |
                         |   |                     |     |
                         |   |  +-----+ +-------+  |     |
                         |   |  | RT  | |  RT   |  |     |
                         |   |  |prod | |stage  |  |     |
                         |   |  +-----+ +-------+  |     |
                         |   |  +-------+           |     |
                         |   |  | RT    |           |     |
                         |   |  | dev   |           |     |
                         |   |  +-------+           |     |
                         |   +--+----+----+---------+     |
                         |      |    |    |               |
                         |   VPC (Shared Services)        |
                         |   10.0.0.0/16                  |
                         +------+----+----+---------------+
                                |    |    |
               +----------------+    |    +----------------+
               |                     |                     |
  +------------v-----------+  +------v-----------+  +------v-----------+
  |   Spoke: Production    |  |  Spoke: Staging  |  |   Spoke: Dev     |
  |                        |  |                  |  |                  |
  |   VPC 10.1.0.0/16     |  |  VPC 10.50.0.0/16|  |  VPC 10.100.0.0/16|
  |   VPC 10.2.0.0/16     |  |  VPC 10.51.0.0/16|  |  VPC 10.101.0.0/16|
  |   ...                  |  |  ...             |  |  ...             |
  |                        |  |                  |  |                  |
  |   TGW Attachment       |  |  TGW Attachment  |  |  TGW Attachment  |
  +------------------------+  +------------------+  +------------------+

  Route Table Isolation:
    prod  <--X--> dev       (no direct routing)
    prod  <--X--> stage     (no direct routing)
    stage <--X--> dev       (no direct routing)
    all   <----> hub        (routed via Transit Gateway)
```

## Features

- **VPC Module** -- Configurable VPC with public, private, and database subnets across 2 AZs
- **Transit Gateway Module** -- Central hub TGW with isolated route tables per environment
- **TGW Attachment Module** -- Attach spoke VPCs to the hub TGW with automatic route propagation
- **CIDR Allocation Strategy** -- Deterministic, non-overlapping CIDR blocks by environment
- **Route Table Isolation** -- Production, staging, and development environments cannot route to each other
- **Cross-Account Access** -- RAM-based TGW sharing across AWS accounts
- **Standardized Naming** -- Consistent `{org}-{group}-{service}-{region}-{env}-{type}` convention
- **Cost Optimization** -- Optional NAT Instance instead of NAT Gateway for dev/test environments

## Quick Start

Set up a 3-account hub-spoke architecture (hub + production + staging):

```hcl
# Hub account -- Transit Gateway
module "tgw" {
  source = "github.com/JIUNG9/terraform-aws-hub-spoke//modules/tgw"

  organization = "myorg"
  project      = "platform"
  environment  = "hub"

  amazon_side_asn = 64512

  environment_route_tables = ["prod", "stage", "dev"]

  tags = {
    ManagedBy = "terraform"
  }
}

# Hub account -- Shared services VPC
module "hub_vpc" {
  source = "github.com/JIUNG9/terraform-aws-hub-spoke//modules/vpc"

  organization = "myorg"
  project      = "platform"
  service      = "shared"
  environment  = "hub"

  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets     = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets    = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_nat_gateway  = true

  tags = {
    ManagedBy = "terraform"
  }
}

# Hub account -- Attach hub VPC to TGW
module "hub_attachment" {
  source = "github.com/JIUNG9/terraform-aws-hub-spoke//modules/tgw-attachment"

  organization = "myorg"
  project      = "platform"
  service      = "shared"
  environment  = "hub"

  transit_gateway_id = module.tgw.transit_gateway_id
  vpc_id             = module.hub_vpc.vpc_id
  subnet_ids         = module.hub_vpc.private_subnet_ids

  route_table_id = module.tgw.route_table_ids["prod"]

  propagate_to_route_table_ids = values(module.tgw.route_table_ids)

  tags = {
    ManagedBy = "terraform"
  }
}

# Production spoke account -- VPC
module "prod_vpc" {
  source = "github.com/JIUNG9/terraform-aws-hub-spoke//modules/vpc"

  providers = {
    aws = aws.prod
  }

  organization = "myorg"
  project      = "commerce"
  service      = "api"
  environment  = "prod"

  vpc_cidr            = "10.1.0.0/16"
  availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets      = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets     = ["10.1.11.0/24", "10.1.12.0/24"]
  database_subnets    = ["10.1.21.0/24", "10.1.22.0/24"]
  enable_nat_gateway  = true

  tags = {
    ManagedBy = "terraform"
  }
}

# Staging spoke account -- VPC
module "stage_vpc" {
  source = "github.com/JIUNG9/terraform-aws-hub-spoke//modules/vpc"

  providers = {
    aws = aws.stage
  }

  organization = "myorg"
  project      = "commerce"
  service      = "api"
  environment  = "stage"

  vpc_cidr            = "10.50.0.0/16"
  availability_zones  = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets      = ["10.50.1.0/24", "10.50.2.0/24"]
  private_subnets     = ["10.50.11.0/24", "10.50.12.0/24"]
  database_subnets    = ["10.50.21.0/24", "10.50.22.0/24"]
  enable_nat_gateway  = true

  tags = {
    ManagedBy = "terraform"
  }
}
```

## Modules

| Module | Description | Source |
|--------|-------------|--------|
| [vpc](./modules/vpc) | VPC with public, private, and database subnets across 2 AZs | `modules/vpc` |
| [tgw](./modules/tgw) | Transit Gateway with environment-isolated route tables | `modules/tgw` |
| [tgw-attachment](./modules/tgw-attachment) | Attach a spoke VPC to Transit Gateway with route propagation | `modules/tgw-attachment` |

## CIDR Allocation Strategy

This project uses a deterministic CIDR allocation strategy to prevent overlap across accounts and environments:

| Environment | CIDR Range | Example VPCs |
|-------------|------------|--------------|
| Hub/Shared  | `10.0.0.0/16` | Shared services, monitoring, CI/CD runners |
| Production  | `10.1.0.0/16` -- `10.49.0.0/16` | API, workers, data pipelines |
| Staging     | `10.50.0.0/16` -- `10.99.0.0/16` | Pre-production mirrors |
| Development | `10.100.0.0/16` -- `10.149.0.0/16` | Dev workloads, experiments |
| Reserved    | `10.150.0.0/16` -- `10.255.0.0/16` | Future expansion |

Each VPC gets a `/16` block, allowing 65,534 usable IPs. Within each VPC:

- **Public subnets**: First block (e.g., `10.1.1.0/24`, `10.1.2.0/24`)
- **Private subnets**: Second block (e.g., `10.1.11.0/24`, `10.1.12.0/24`)
- **Database subnets**: Third block (e.g., `10.1.21.0/24`, `10.1.22.0/24`)

## Naming Convention

All resources follow the pattern:

```
{org}-{group}-{service}-{region}-{env}-{type}
```

| Component | Description | Example |
|-----------|-------------|---------|
| `org` | Organization identifier | `myorg` |
| `group` | Project or team group | `platform` |
| `service` | Service name | `api` |
| `region` | AWS region short code | `apne2` |
| `env` | Environment | `prod`, `stage`, `dev` |
| `type` | Resource type suffix | `vpc`, `tgw`, `subnet` |

Example: `myorg-platform-shared-apne2-hub-vpc`

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.10.0 |
| AWS Provider | ~> 5.0 |

## Examples

- [Complete](./examples/complete) -- Hub account with Transit Gateway + 2 spoke VPCs (prod/stage) with full isolation
- [Simple](./examples/simple) -- Minimal hub + 1 spoke setup

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](./CONTRIBUTING.md) before submitting a pull request.

## License

MIT License. See [LICENSE](./LICENSE) for details.

## Author

**June Gu**
- LinkedIn: [linkedin.com/in/junegu](https://linkedin.com/in/junegu)
- Medium: [medium.com/@June-Gu](https://medium.com/@June-Gu)

Site Reliability Engineer, 5+ years building cloud infrastructure at scale. The modules come from patterns I used to run a multi-account AWS estate serving production microservices.

## Related Articles

- [Designing a Hub-Spoke AWS Multi-Account Architecture with Transit Gateway](https://medium.com/@June-Gu) — Design decisions and CIDR allocation strategy behind these modules
- [Terraform Module Design: Zero-Magic Principles for Multi-Account AWS](https://medium.com/@June-Gu) — The three-layer architecture and naming conventions
