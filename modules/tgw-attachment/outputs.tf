# ------------------------------------------------------------------------------
# Attachment Outputs
# ------------------------------------------------------------------------------

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.id
}

output "transit_gateway_attachment_vpc_owner_id" {
  description = "AWS account ID of the VPC owner"
  value       = aws_ec2_transit_gateway_vpc_attachment.this.vpc_owner_id
}

# ------------------------------------------------------------------------------
# Route Table Association
# ------------------------------------------------------------------------------

output "route_table_association_id" {
  description = "ID of the TGW route table association"
  value       = aws_ec2_transit_gateway_route_table_association.this.id
}

# ------------------------------------------------------------------------------
# Naming
# ------------------------------------------------------------------------------

output "name_prefix" {
  description = "The computed name prefix used for all resources in this module"
  value       = local.name_prefix
}
