# ------------------------------------------------------------------------------
# Transit Gateway
# ------------------------------------------------------------------------------

output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = module.tgw.transit_gateway_id
}

output "tgw_route_table_ids" {
  description = "Map of environment to TGW route table IDs"
  value       = module.tgw.route_table_ids
}

# ------------------------------------------------------------------------------
# Hub VPC
# ------------------------------------------------------------------------------

output "hub_vpc_id" {
  description = "ID of the hub shared services VPC"
  value       = module.hub_vpc.vpc_id
}

output "hub_vpc_cidr" {
  description = "CIDR block of the hub VPC"
  value       = module.hub_vpc.vpc_cidr_block
}

# ------------------------------------------------------------------------------
# Production Spoke
# ------------------------------------------------------------------------------

output "prod_vpc_id" {
  description = "ID of the production VPC"
  value       = module.prod_vpc.vpc_id
}

output "prod_vpc_cidr" {
  description = "CIDR block of the production VPC"
  value       = module.prod_vpc.vpc_cidr_block
}

output "prod_tgw_attachment_id" {
  description = "ID of the production TGW attachment"
  value       = module.prod_attachment.transit_gateway_attachment_id
}

# ------------------------------------------------------------------------------
# Staging Spoke
# ------------------------------------------------------------------------------

output "stage_vpc_id" {
  description = "ID of the staging VPC"
  value       = module.stage_vpc.vpc_id
}

output "stage_vpc_cidr" {
  description = "CIDR block of the staging VPC"
  value       = module.stage_vpc.vpc_cidr_block
}

output "stage_tgw_attachment_id" {
  description = "ID of the staging TGW attachment"
  value       = module.stage_attachment.transit_gateway_attachment_id
}
