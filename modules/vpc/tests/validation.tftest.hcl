# Plan-only tests for the input validations on the vpc module.
#
# The AWS provider is mocked, so these run with no credentials and create
# nothing. Each rule gets a case that must pass and a case that must be
# rejected: a validation that has never been seen to reject anything is
# unproven.
#
#   cd modules/vpc && terraform init -backend=false && terraform test

mock_provider "aws" {}

variables {
  organization       = "acme-corp"
  project            = "platform"
  service            = "network"
  environment        = "dev"
  vpc_cidr           = "10.100.0.0/16"
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnets     = ["10.100.0.0/24", "10.100.1.0/24"]
  private_subnets    = ["10.100.10.0/24", "10.100.11.0/24"]
}

run "baseline_plans" {
  command = plan

  assert {
    condition     = aws_vpc.this.cidr_block == "10.100.0.0/16"
    error_message = "the baseline inputs should plan a VPC with the given CIDR"
  }
}

# --- environment ---------------------------------------------------------------

run "environment_unknown_is_rejected" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}

# --- vpc_cidr ------------------------------------------------------------------

run "vpc_cidr_not_a_cidr_is_rejected" {
  command = plan

  variables {
    vpc_cidr = "10.100.0.0"
  }

  expect_failures = [var.vpc_cidr]
}

# --- availability_zones --------------------------------------------------------

run "single_az_is_rejected" {
  command = plan

  variables {
    availability_zones = ["ap-northeast-2a"]
    public_subnets     = ["10.100.0.0/24"]
    private_subnets    = ["10.100.10.0/24"]
  }

  expect_failures = [var.availability_zones]
}

# --- enable_nat_gateway --------------------------------------------------------

run "nat_without_public_subnet_is_rejected" {
  command = plan

  variables {
    public_subnets     = []
    enable_nat_gateway = true
  }

  expect_failures = [var.enable_nat_gateway]
}

run "no_nat_without_public_subnet_plans" {
  command = plan

  variables {
    public_subnets     = []
    enable_nat_gateway = false
  }

  assert {
    condition     = length(aws_subnet.public) == 0
    error_message = "no public subnets should be planned when none are given"
  }
}

# --- enforce_cidr_convention ---------------------------------------------------

run "convention_off_allows_any_cidr" {
  command = plan

  variables {
    environment = "prod"
    vpc_cidr    = "10.200.0.0/16"
  }
}

run "convention_prod_in_band_plans" {
  command = plan

  variables {
    enforce_cidr_convention = true
    environment             = "prod"
    vpc_cidr                = "10.10.0.0/16"
  }
}

run "convention_prod_out_of_band_is_rejected" {
  command = plan

  variables {
    enforce_cidr_convention = true
    environment             = "prod"
    vpc_cidr                = "10.60.0.0/16"
  }

  expect_failures = [var.enforce_cidr_convention]
}

run "convention_stage_in_band_plans" {
  command = plan

  variables {
    enforce_cidr_convention = true
    environment             = "stage"
    vpc_cidr                = "10.75.0.0/16"
  }
}

run "convention_stage_out_of_band_is_rejected" {
  command = plan

  variables {
    enforce_cidr_convention = true
    environment             = "stage"
    vpc_cidr                = "10.100.0.0/16"
  }

  expect_failures = [var.enforce_cidr_convention]
}

run "convention_dev_in_band_plans" {
  command = plan

  variables {
    enforce_cidr_convention = true
    environment             = "dev"
    vpc_cidr                = "10.120.0.0/16"
  }
}

run "convention_dev_out_of_band_is_rejected" {
  command = plan

  variables {
    enforce_cidr_convention = true
    environment             = "dev"
    vpc_cidr                = "10.20.0.0/16"
  }

  expect_failures = [var.enforce_cidr_convention]
}

run "convention_hub_is_exempt" {
  command = plan

  variables {
    enforce_cidr_convention = true
    environment             = "hub"
    vpc_cidr                = "10.250.0.0/16"
  }
}
