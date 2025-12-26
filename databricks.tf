# Wait on Credential Due to Race Condition
# https://kb.databricks.com/en_US/terraform/failed-credential-validation-checks-error-with-terraform 
resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "30s"
}

# ==============================================================================
# Credential Configuration
# ==============================================================================

resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  role_arn         = aws_iam_role.cross_account_role.arn
  credentials_name = "${var.resource_prefix}-credentials"
  depends_on       = [time_sleep.wait_30_seconds]
}

# ==============================================================================
# Storage Configuration
# ==============================================================================

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage_bucket.id
  storage_configuration_name = "${var.resource_prefix}-storage"
}

# ==============================================================================
# Network Configuration
# ==============================================================================

resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.resource_prefix}-network"
  security_group_ids = var.security_group_ids
  subnet_ids         = values(aws_subnet.private_compute)[*].id
  vpc_id             = var.vpc_id
  vpc_endpoints {
    dataplane_relay = [var.databricks_scc_vpce_id]
    rest_api        = [var.databricks_rest_vpce_id]
  }
}

# ==============================================================================
# Workspace Configuration with Deployment Name
# ==============================================================================

resource "databricks_mws_workspaces" "workspace" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  aws_region                 = var.region
  workspace_name             = var.resource_prefix
  deployment_name            = var.deployment_name
  credentials_id             = databricks_mws_credentials.this.credentials_id
  storage_configuration_id   = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id                 = databricks_mws_networks.this.network_id
  private_access_settings_id = var.databricks_private_access_settings_id

  managed_services_customer_managed_key_id = var.databricks_managed_services_key_id
  storage_customer_managed_key_id          = var.databricks_workspace_storage_key_id
  pricing_tier                             = "ENTERPRISE"

  depends_on = [databricks_mws_networks.this]
}

# ==============================================================================
# Metastore Assignment
# ==============================================================================

resource "databricks_metastore_assignment" "default_metastore" {
  workspace_id = databricks_mws_workspaces.workspace.workspace_id
  metastore_id = var.databricks_metastore_id
}

# Enable Compliance Security Profile (CSP) on the Databricks Workspace.
resource "databricks_compliance_security_profile_workspace_setting" "this" {
  compliance_security_profile_workspace {
    is_enabled           = true
    compliance_standards = var.compliance_standards
  }
}
