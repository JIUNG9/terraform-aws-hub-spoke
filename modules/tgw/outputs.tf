# ------------------------------------------------------------------------------
# Transit Gateway Outputs
# ------------------------------------------------------------------------------

output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.arn
}

output "transit_gateway_owner_id" {
  description = "AWS account ID of the Transit Gateway owner"
  value       = aws_ec2_transit_gateway.this.owner_id
}

# ------------------------------------------------------------------------------
# Route Table Outputs
# ------------------------------------------------------------------------------

output "route_table_ids" {
  description = "Map of environment name to TGW route table ID"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.id }
}

output "hub_route_table_id" {
  description = "ID of the hub TGW route table. Associate the hub attachment with it and propagate every spoke attachment into it"
  value       = aws_ec2_transit_gateway_route_table.hub.id
}

# ------------------------------------------------------------------------------
# RAM Share Outputs
# ------------------------------------------------------------------------------

output "ram_resource_share_arn" {
  description = "ARN of the RAM resource share (null if RAM sharing is disabled)"
  value       = try(aws_ram_resource_share.this[0].arn, null)
}

# ------------------------------------------------------------------------------
# Naming
# ------------------------------------------------------------------------------

output "name_prefix" {
  description = "The computed name prefix used for all resources in this module"
  value       = local.name_prefix
}
