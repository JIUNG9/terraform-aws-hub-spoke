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

variable "environment" {
  description = "Environment name for the hub account (e.g., hub)"
  type        = string
  default     = "hub"
}

variable "region" {
  description = "AWS region (used for naming convention)"
  type        = string
  default     = "ap-northeast-2"
}

# ------------------------------------------------------------------------------
# Transit Gateway Configuration
# ------------------------------------------------------------------------------

variable "amazon_side_asn" {
  description = "Private ASN for the Amazon side of the Transit Gateway. Must be in 64512-65534 or 4200000000-4294967294 range."
  type        = number
  default     = 64512

  validation {
    condition     = (var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534) || (var.amazon_side_asn >= 4200000000 && var.amazon_side_asn <= 4294967294)
    error_message = "amazon_side_asn must be in range 64512-65534 or 4200000000-4294967294."
  }
}

variable "auto_accept_shared_attachments" {
  description = "Whether to auto-accept cross-account attachment requests"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Route Table Configuration
# ------------------------------------------------------------------------------

variable "environment_route_tables" {
  description = "List of environment names to create isolated TGW route tables for"
  type        = list(string)
  default     = ["prod", "stage", "dev"]

  validation {
    condition     = length(var.environment_route_tables) > 0
    error_message = "At least one environment route table must be specified."
  }
}

# ------------------------------------------------------------------------------
# RAM Sharing (cross-account)
# ------------------------------------------------------------------------------

variable "enable_ram_sharing" {
  description = "Whether to share the Transit Gateway via AWS RAM for cross-account access"
  type        = bool
  default     = false
}

variable "allow_external_principals" {
  description = "Whether to allow external principals (accounts outside the AWS Organization) in RAM share"
  type        = bool
  default     = false
}

variable "ram_principal_arns" {
  description = "List of AWS account IDs or Organization ARNs to share the TGW with via RAM"
  type        = list(string)
  default     = []
}

# ------------------------------------------------------------------------------
# Tags
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
