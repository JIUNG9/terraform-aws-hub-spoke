variable "organization" {
  description = "Organization identifier used in resource naming"
  type        = string
  default     = "myorg"
}

variable "region" {
  description = "AWS region to deploy all resources in"
  type        = string
  default     = "ap-northeast-2"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}

variable "prod_account_id" {
  description = "AWS account ID for the production spoke account"
  type        = string
}

variable "stage_account_id" {
  description = "AWS account ID for the staging spoke account"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default = {
    Example = "complete"
  }
}
