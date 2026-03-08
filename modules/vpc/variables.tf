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
# Tags
# ------------------------------------------------------------------------------

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
