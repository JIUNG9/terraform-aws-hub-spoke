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
# Local Values
# ------------------------------------------------------------------------------

locals {
  region_short = replace(replace(replace(replace(replace(
    var.region,
    "ap-northeast-1", "apne1"),
    "ap-northeast-2", "apne2"),
    "us-east-1", "use1"),
    "us-west-2", "usw2"),
    "eu-west-1", "euw1"
  )

  name_prefix = "${var.organization}-${var.project}-${local.region_short}-${var.environment}"

  common_tags = merge(var.tags, {
    Organization = var.organization
    Project      = var.project
    Environment  = var.environment
    ManagedBy    = "terraform"
    Module       = "terraform-aws-hub-spoke//modules/tgw"
  })
}

# ------------------------------------------------------------------------------
# Transit Gateway
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "this" {
  description = "Transit Gateway for ${local.name_prefix} hub-spoke architecture"

  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments ? "enable" : "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tgw"
  })
}

# ------------------------------------------------------------------------------
# Route Tables (one per environment for isolation)
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each = toset(var.environment_route_tables)

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}-tgw-rt-${each.key}"
    Environment = each.key
  })
}

# ------------------------------------------------------------------------------
# RAM Share (for cross-account TGW sharing)
# ------------------------------------------------------------------------------

resource "aws_ram_resource_share" "this" {
  count = var.enable_ram_sharing ? 1 : 0

  name                      = "${local.name_prefix}-tgw-share"
  allow_external_principals = var.allow_external_principals

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tgw-share"
  })
}

resource "aws_ram_resource_association" "this" {
  count = var.enable_ram_sharing ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_principal_association" "this" {
  count = var.enable_ram_sharing ? length(var.ram_principal_arns) : 0

  principal          = var.ram_principal_arns[count.index]
  resource_share_arn = aws_ram_resource_share.this[0].arn
}
