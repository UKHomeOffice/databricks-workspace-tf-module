# High Level AWS Variables
variable "region" {
  description = "The primary AWS region to deploy resources to"
  type        = string
  default     = "eu-west-2"
}

variable "aws_partition" {
  description = "AWS partition to use for ARNs and policies"
  type        = string
  default     = "aws"
}

# High Level Databricks Variables
variable "databricks_account_id" {
  description = "ID of the Databricks account to deploy to."
  type        = string
  sensitive   = true
}

variable "databricks_provider_host" {
  description = "Databricks provider host URL"
  type        = string
  default     = "https://accounts.cloud.databricks.com"
}

variable "databricks_metastore_id" {
  description = "ID of the Databricks metastore for the current cloud region and Databricks account"
  type        = string
  default     = null
}

# Customer-managed VPC Networking Configuration. Keep subnets in case Core Cloud decide to centralise vending of them
variable "vpc_id" {
  description = "Custom VPC ID"
  type        = string
  default     = null
}

variable "vpc_cidr_range" {
  description = "Custom VPC CIDR range. e.g. 10.0.0.0/22"
  type        = string
  default     = null
}

variable "private_compute_subnet_config" {
  description = "Map of CIDRs and AZs to use when creating private subnet IDs"
  type = map(object({
    cidr = string
    az   = string
  }))
  default     = null
}

variable "private_route_table_id" {
  description = "ID of the private route table to associate the backend PrivateLink endpoint subnets with"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "Security group ID"
  type        = list(string)
  default     = null
}

variable "sg_egress_ports" {
  description = "List of egress ports for security groups."
  type        = list(string)
  nullable    = true
  default     = [null]
}

# Databricks variables
variable "deployment_name" {
  description = "Deployment name for the workspace. Must first be enabled by a Databricks representative."
  default     = null
  type        = string
  nullable    = true
}

variable "databricks_scc_vpce_id" {
  description = "ID of the Databricks VPC endpoint registration for SCC Relay"
  type        = string
  default     = null
}

variable "databricks_rest_vpce_id" {
  description = "ID of the Databricks VPC endpoint registration for REST"
  type        = string
  default     = null
}

variable "databricks_workspace_storage_key_id" {
  description = "ID of the Databricks encryption key to use for encrypting workspace storage."
  type        = string
  default     = null
}

variable "databricks_managed_services_key_id" {
  description = "ID of the Databricks encryption key to use for encrypting managed services."
  type        = string
  default     = null
}

variable "databricks_private_access_settings_id" {
  description = "ID of the Databricks Private Access Settings (PAS) object to use for frontend PrivateLink to the workspace."
  type        = string
  default     = null
}

variable "databricks_network_policy_id" {
  description = "ID of the Databricks Network Policy object to apply to this workspace."
  type        = string
  default     = null
}

variable "artifact_storage_bucket" {
  description = "Artifact storage bucket for VPC endpoint policy."
  type        = map(list(string))
  default = {
    "eu-west-1" = ["databricks-prod-artifacts-eu-west-1"]
    "eu-west-2" = ["databricks-prod-artifacts-eu-west-2"]
  }
}

variable "audit_log_delivery_exists" {
  description = "If audit log delivery is already configured"
  type        = bool
  default     = false
}

# AWS variables
variable "workspace_storage_key_arn" {
  description = "ARN of the KMS key used for encryption of the S3 bucket used for workspace root."
  type        = string
}

# Databricks compliance and security (inc. SAT)
variable "compliance_standards" {
  description = "List of compliance standards."
  type        = list(string)
  nullable    = true
  default     = ["CYBER_ESSENTIAL_PLUS"]
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

# Common variables to be applied to a large number of resources
variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-.]{1,26}$", var.resource_prefix))
    error_message = "Invalid resource prefix. Allowed 40 characters containing only a-z, 0-9, -, ."
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
