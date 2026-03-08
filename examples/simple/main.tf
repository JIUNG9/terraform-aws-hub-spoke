terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ------------------------------------------------------------------------------
# Provider — Single account (hub + spoke in the same account)
# Suitable for testing and learning
# ------------------------------------------------------------------------------

provider "aws" {
  region = "ap-northeast-2"

  default_tags {
    tags = {
      Project   = "hub-spoke-simple"
      ManagedBy = "terraform"
    }
  }
}

# ------------------------------------------------------------------------------
# Transit Gateway
# ------------------------------------------------------------------------------

module "tgw" {
  source = "../../modules/tgw"

  organization = "myorg"
  project      = "demo"
  environment  = "hub"
  region       = "ap-northeast-2"

  amazon_side_asn          = 64512
  environment_route_tables = ["prod"]

  tags = {
    Example = "simple"
  }
}

# ------------------------------------------------------------------------------
# Hub VPC
# ------------------------------------------------------------------------------

module "hub_vpc" {
  source = "../../modules/vpc"

  organization = "myorg"
  project      = "demo"
  service      = "shared"
  environment  = "hub"
  region       = "ap-northeast-2"

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets   = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_nat_gateway = true

  tags = {
    Example = "simple"
  }
}

module "hub_attachment" {
  source = "../../modules/tgw-attachment"

  organization = "myorg"
  project      = "demo"
  service      = "shared"
  environment  = "hub"
  region       = "ap-northeast-2"

  transit_gateway_id = module.tgw.transit_gateway_id
  vpc_id             = module.hub_vpc.vpc_id
  subnet_ids         = module.hub_vpc.private_subnet_ids

  route_table_id               = module.tgw.route_table_ids["prod"]
  propagate_to_route_table_ids = values(module.tgw.route_table_ids)

  vpc_route_table_ids  = compact([module.hub_vpc.private_route_table_id])
  tgw_destination_cidr = "10.0.0.0/8"

  tags = {
    Example = "simple"
  }
}

# ------------------------------------------------------------------------------
# Single Spoke VPC (Production)
# ------------------------------------------------------------------------------

module "spoke_vpc" {
  source = "../../modules/vpc"

  organization = "myorg"
  project      = "demo"
  service      = "app"
  environment  = "prod"
  region       = "ap-northeast-2"

  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets    = ["10.1.11.0/24", "10.1.12.0/24"]
  database_subnets   = ["10.1.21.0/24", "10.1.22.0/24"]
  enable_nat_gateway = true

  tags = {
    Example = "simple"
  }
}

module "spoke_attachment" {
  source = "../../modules/tgw-attachment"

  organization = "myorg"
  project      = "demo"
  service      = "app"
  environment  = "prod"
  region       = "ap-northeast-2"

  transit_gateway_id = module.tgw.transit_gateway_id
  vpc_id             = module.spoke_vpc.vpc_id
  subnet_ids         = module.spoke_vpc.private_subnet_ids

  route_table_id               = module.tgw.route_table_ids["prod"]
  propagate_to_route_table_ids = [module.tgw.route_table_ids["prod"]]

  vpc_route_table_ids  = compact([module.spoke_vpc.private_route_table_id])
  tgw_destination_cidr = "10.0.0.0/8"

  tags = {
    Example = "simple"
  }
}
