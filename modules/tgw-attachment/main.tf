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

  name_prefix = "${var.organization}-${var.project}-${var.service}-${local.region_short}-${var.environment}"

  common_tags = merge(var.tags, {
    Organization = var.organization
    Project      = var.project
    Service      = var.service
    Environment  = var.environment
    ManagedBy    = "terraform"
    Module       = "terraform-aws-hub-spoke//modules/tgw-attachment"
  })
}

# ------------------------------------------------------------------------------
# Transit Gateway VPC Attachment
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tgw-attachment"
  })
}

# ------------------------------------------------------------------------------
# Route Table Association
# Attach this VPC to the correct environment route table
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.route_table_id
}

# ------------------------------------------------------------------------------
# Route Table Propagation
# Propagate this VPC's routes to the specified route tables
# (typically its own environment RT + the hub RT)
# ------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  count = length(var.propagate_to_route_table_ids)

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = var.propagate_to_route_table_ids[count.index]
}

# ------------------------------------------------------------------------------
# VPC Route Table Entries
# Add routes in the VPC route tables pointing to the TGW
# ------------------------------------------------------------------------------

resource "aws_route" "private_to_tgw" {
  count = length(var.vpc_route_table_ids)

  route_table_id         = var.vpc_route_table_ids[count.index]
  destination_cidr_block = var.tgw_destination_cidr
  transit_gateway_id     = var.transit_gateway_id
}
