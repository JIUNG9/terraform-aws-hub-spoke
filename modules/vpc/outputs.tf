# ------------------------------------------------------------------------------
# VPC Outputs
# ------------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.this.arn
}

# ------------------------------------------------------------------------------
# Subnet Outputs
# ------------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "database_subnet_cidrs" {
  description = "List of database subnet CIDR blocks"
  value       = aws_subnet.database[*].cidr_block
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = try(aws_db_subnet_group.this[0].name, null)
}

# ------------------------------------------------------------------------------
# Route Table Outputs
# ------------------------------------------------------------------------------

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = try(aws_route_table.public[0].id, null)
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = try(aws_route_table.private[0].id, null)
}

output "database_route_table_id" {
  description = "ID of the database route table"
  value       = try(aws_route_table.database[0].id, null)
}

# ------------------------------------------------------------------------------
# Gateway Outputs
# ------------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = try(aws_nat_gateway.this[0].id, null)
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = try(aws_eip.nat[0].public_ip, null)
}

# ------------------------------------------------------------------------------
# VPC Endpoint Outputs
# ------------------------------------------------------------------------------

output "gateway_endpoint_ids" {
  description = "Map of Gateway VPC endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.gateway : k => v.id }
}

output "interface_endpoint_ids" {
  description = "Map of Interface VPC endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

# ------------------------------------------------------------------------------
# Naming
# ------------------------------------------------------------------------------

output "name_prefix" {
  description = "The computed name prefix used for all resources in this module"
  value       = local.name_prefix
}
