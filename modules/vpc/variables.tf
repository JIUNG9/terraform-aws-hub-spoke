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

  validation {
    condition     = contains(["prod", "stage", "dev", "hub", "shared"], var.environment)
    error_message = "Environment must be one of: prod, stage, dev, hub, shared."
  }
}

variable "region" {
  description = "AWS region (used for naming convention). Defaults to provider region if not set."
  type        = string
  default     = "ap-northeast-2"
}

# ------------------------------------------------------------------------------
# VPC Configuration
# ------------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "enforce_cidr_convention" {
  description = "Enforce CIDR range by environment (prod: 10.0-49.x, stage: 10.50-99.x, dev: 10.100-149.x)"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "List of availability zones for subnet placement (must provide at least 2)"
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones must be specified."
  }
}

# ------------------------------------------------------------------------------
# Subnet Configuration
# ------------------------------------------------------------------------------

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = []
}

variable "database_subnets" {
  description = "List of CIDR blocks for database subnets (one per AZ)"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
  description = "Whether to auto-assign public IPs in public subnets"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# Gateway Configuration
# ------------------------------------------------------------------------------

variable "create_igw" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# Flow Logs
# ------------------------------------------------------------------------------

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs to CloudWatch"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs in CloudWatch"
  type        = number
  default     = 30
}

# ------------------------------------------------------------------------------
# VPC Endpoints
# ------------------------------------------------------------------------------

variable "enable_vpc_endpoints" {
  description = "Enable Gateway VPC endpoints (S3, DynamoDB). Free."
  type        = bool
  default     = false
}

variable "gateway_endpoint_services" {
  description = "List of Gateway endpoint services"
  type        = list(string)
  default     = ["s3", "dynamodb"]
}

variable "enable_interface_endpoints" {
  description = "Enable Interface VPC endpoints. Each costs ~$7.30/mo."
  type        = bool
  default     = false
}

variable "interface_endpoint_services" {
  description = "List of Interface endpoint services"
  type        = list(string)
  default     = ["ssm", "ssmmessages", "ec2messages"]
}

# ------------------------------------------------------------------------------
# Security Hardening
# ------------------------------------------------------------------------------

variable "restrict_default_security_group" {
  description = "Restrict the default security group to have no rules (Checkov CKV2_AWS_12)"
  type        = bool
  default     = true
}

variable "enable_ssm_metadata" {
  description = "Export VPC metadata to SSM Parameter Store for cross-stack reference"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# Tags
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
