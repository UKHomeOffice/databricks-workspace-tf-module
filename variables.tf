variable "region" {
  description = "The primary AWS region to deploy resources to"
  type        = string
  default     = "eu-west-2"
}

variable "admin_user" {
  description = "Email of the admin user for the workspace and workspace catalog."
  type        = string
}

variable "artifact_storage_bucket" {
  description = "Artifact storage bucket for VPC endpoint policy."
  type        = map(list(string))
  default = {
    "eu-west-1"      = ["databricks-prod-artifacts-eu-west-1"]
    "eu-west-2"      = ["databricks-prod-artifacts-eu-west-2"]
  }
}

variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
  default     = false
}

variable "aws_account_id" {
  description = "ID of the AWS account."
  type        = string
  sensitive   = true
}

variable "aws_partition" {
  description = "AWS partition to use for ARNs and policies"
  type        = string
  default     = "aws"
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
  default     = null
}

variable "compliance_standards" {
  description = "List of compliance standards."
  type        = list(string)
  nullable    = true
}

variable "custom_private_subnet_ids" {
  description = "List of custom private subnet IDs"
  type        = list(string)
  default     = null
}

variable "custom_relay_vpce_id" {
  description = "Custom Relay VPC Endpoint ID"
  type        = string
  default     = null
}

variable "custom_rest_vpce_id" {
  description = "Custom REST VPC Endpoint ID"
  type        = string
  default     = null
}

variable "custom_sg_id" {
  description = "Custom security group ID"
  type        = string
  default     = null
}

variable "custom_vpc_id" {
  description = "Custom VPC ID"
  type        = string
  default     = null
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "databricks_provider_host" {
  description = "Databricks provider host URL"
  type        = string
  default     = null # Will be computed based on databricks_gov_shard

  validation {
    condition     = var.databricks_provider_host == null || can(regex("^https://(accounts|accounts-dod)\\.cloud\\.databricks\\.(com|us|mil)$", var.databricks_provider_host))
    error_message = "Invalid databricks_provider_host. Must be a valid Databricks accounts URL."
  }
}

variable "enable_compliance_security_profile" {
  description = "Flag to enable the compliance security profile."
  type        = bool
  sensitive   = true
  default     = true
}

variable "enable_security_analysis_tool" {
  description = "Flag to enable the security analysis tool."
  type        = bool
  sensitive   = true
  default     = false
}

variable "metastore_exists" {
  description = "If a metastore exists"
  type        = bool
}

variable "private_subnets_cidr" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  nullable    = true
  default     = [null]
}

# Region name configuration
# This variable allows mapping regions to multiple name properties:
# - primary_name: The main region name (required)
# - secondary_name: An optional secondary region name (e.g., for DoD)
#
# Example usage:
# var.region_name_config["eu-west-2"].primary_name   # Get primary name
# var.region_name_config["eu-west-2"].secondary_name # Get secondary name
# var.region_name_config["eu-west-2"].region_type    # Get region type
variable "region_name_config" {
  description = "Region name configuration with multiple properties per region"
  type = map(object({
    primary_name   = string
    secondary_name = optional(string)
    region_type    = optional(string, "commercial")
  }))
  default = {
    "eu-west-1" = {
      primary_name = "ireland"
    }
    "eu-west-2" = {
      primary_name = "london"
    }
  }
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-.]{1,26}$", var.resource_prefix))
    error_message = "Invalid resource prefix. Allowed 40 characters containing only a-z, 0-9, -, ."
  }
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
  nullable    = true
  default     = [null]
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
