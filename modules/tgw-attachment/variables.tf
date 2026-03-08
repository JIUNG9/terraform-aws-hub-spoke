# ------------------------------------------------------------------------------
# Naming Variables
# ------------------------------------------------------------------------------

variable "organization" {
  description = "Organization identifier used in resource naming"
  type        = string
}

variable "project" {
  description = "Project or team group name used in resource naming"
  type        = string
}

variable "service" {
  description = "Service name used in resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, stage, dev, hub)"
  type        = string
}

variable "region" {
  description = "AWS region (used for naming convention)"
  type        = string
  default     = "ap-northeast-2"
}

# ------------------------------------------------------------------------------
# Transit Gateway Attachment Configuration
# ------------------------------------------------------------------------------

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach to"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC to attach to the Transit Gateway"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs in the VPC to place the TGW attachment ENIs (one per AZ, typically private subnets)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

# ------------------------------------------------------------------------------
# Route Table Configuration
# ------------------------------------------------------------------------------

variable "route_table_id" {
  description = "ID of the TGW route table to associate this attachment with (determines which environment this VPC belongs to)"
  type        = string
}

variable "propagate_to_route_table_ids" {
  description = "List of TGW route table IDs to propagate this VPC's routes to. Typically includes the attachment's own RT and the hub RT."
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# VPC Routing
# ------------------------------------------------------------------------------

variable "vpc_route_table_ids" {
  description = "List of VPC route table IDs to add TGW routes to (e.g., private and database route tables)"
  type        = list(string)
  default     = []
}

variable "tgw_destination_cidr" {
  description = "Destination CIDR block for TGW routes added to VPC route tables (e.g., 10.0.0.0/8 for all internal traffic)"
  type        = string
  default     = "10.0.0.0/8"
}

# ------------------------------------------------------------------------------
# Tags
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
