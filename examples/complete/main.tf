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
# Provider Configuration
# Hub account is the default provider; spoke accounts use assume_role
# Replace account IDs with your own
# ------------------------------------------------------------------------------

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "hub-spoke-demo"
      ManagedBy = "terraform"
    }
  }
}

provider "aws" {
  alias  = "prod"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.prod_account_id}:role/TerraformCrossAccountRole"
  }

  default_tags {
    tags = {
      Project   = "hub-spoke-demo"
      ManagedBy = "terraform"
    }
  }
}

provider "aws" {
  alias  = "stage"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.stage_account_id}:role/TerraformCrossAccountRole"
  }

  default_tags {
    tags = {
      Project   = "hub-spoke-demo"
      ManagedBy = "terraform"
    }
  }
}

# ------------------------------------------------------------------------------
# Transit Gateway (Hub Account)
# ------------------------------------------------------------------------------

module "tgw" {
  source = "../../modules/tgw"

  organization = var.organization
  project      = "platform"
  environment  = "hub"
  region       = var.region

  amazon_side_asn                = 64512
  auto_accept_shared_attachments = true
  environment_route_tables       = ["prod", "stage"]

  enable_ram_sharing = true
  ram_principal_arns = [
    var.prod_account_id,
    var.stage_account_id,
  ]

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Hub VPC (Shared Services)
# ------------------------------------------------------------------------------

module "hub_vpc" {
  source = "../../modules/vpc"

  organization = var.organization
  project      = "platform"
  service      = "shared"
  environment  = "hub"
  region       = var.region

  vpc_cidr           = "10.0.0.0/16"
  availability_zones = var.availability_zones
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnets   = ["10.0.21.0/24", "10.0.22.0/24"]
  enable_nat_gateway = true
  enable_flow_logs   = true

  tags = var.tags
}

# Hub VPC -> TGW Attachment
module "hub_attachment" {
  source = "../../modules/tgw-attachment"

  organization = var.organization
  project      = "platform"
  service      = "shared"
  environment  = "hub"
  region       = var.region

  transit_gateway_id = module.tgw.transit_gateway_id
  vpc_id             = module.hub_vpc.vpc_id
  subnet_ids         = module.hub_vpc.private_subnet_ids

  # Hub is associated with prod RT (it needs to be reachable from all)
  route_table_id = module.tgw.route_table_ids["prod"]

  # Propagate hub routes to ALL environment route tables
  propagate_to_route_table_ids = values(module.tgw.route_table_ids)

  # Add return routes in hub VPC
  vpc_route_table_ids  = compact([module.hub_vpc.private_route_table_id, module.hub_vpc.database_route_table_id])
  tgw_destination_cidr = "10.0.0.0/8"

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Production Spoke VPC
# ------------------------------------------------------------------------------

module "prod_vpc" {
  source = "../../modules/vpc"

  providers = {
    aws = aws.prod
  }

  organization = var.organization
  project      = "commerce"
  service      = "api"
  environment  = "prod"
  region       = var.region

  vpc_cidr           = "10.1.0.0/16"
  availability_zones = var.availability_zones
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets    = ["10.1.11.0/24", "10.1.12.0/24"]
  database_subnets   = ["10.1.21.0/24", "10.1.22.0/24"]
  enable_nat_gateway = true
  enable_flow_logs   = true

  tags = var.tags
}

# Production VPC -> TGW Attachment
module "prod_attachment" {
  source = "../../modules/tgw-attachment"

  providers = {
    aws = aws.prod
  }

  organization = var.organization
  project      = "commerce"
  service      = "api"
  environment  = "prod"
  region       = var.region

  transit_gateway_id = module.tgw.transit_gateway_id
  vpc_id             = module.prod_vpc.vpc_id
  subnet_ids         = module.prod_vpc.private_subnet_ids

  route_table_id = module.tgw.route_table_ids["prod"]

  propagate_to_route_table_ids = [
    module.tgw.route_table_ids["prod"],
  ]

  vpc_route_table_ids  = compact([module.prod_vpc.private_route_table_id, module.prod_vpc.database_route_table_id])
  tgw_destination_cidr = "10.0.0.0/8"

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Staging Spoke VPC
# ------------------------------------------------------------------------------

module "stage_vpc" {
  source = "../../modules/vpc"

  providers = {
    aws = aws.stage
  }

  organization = var.organization
  project      = "commerce"
  service      = "api"
  environment  = "stage"
  region       = var.region

  vpc_cidr           = "10.50.0.0/16"
  availability_zones = var.availability_zones
  public_subnets     = ["10.50.1.0/24", "10.50.2.0/24"]
  private_subnets    = ["10.50.11.0/24", "10.50.12.0/24"]
  database_subnets   = ["10.50.21.0/24", "10.50.22.0/24"]
  enable_nat_gateway = true

  tags = var.tags
}

# Staging VPC -> TGW Attachment
module "stage_attachment" {
  source = "../../modules/tgw-attachment"

  providers = {
    aws = aws.stage
  }

  organization = var.organization
  project      = "commerce"
  service      = "api"
  environment  = "stage"
  region       = var.region

  transit_gateway_id = module.tgw.transit_gateway_id
  vpc_id             = module.stage_vpc.vpc_id
  subnet_ids         = module.stage_vpc.private_subnet_ids

  route_table_id = module.tgw.route_table_ids["stage"]

  propagate_to_route_table_ids = [
    module.tgw.route_table_ids["stage"],
  ]

  vpc_route_table_ids  = compact([module.stage_vpc.private_route_table_id, module.stage_vpc.database_route_table_id])
  tgw_destination_cidr = "10.0.0.0/8"

  tags = var.tags
}
