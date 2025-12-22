# databricks-workspace-tf-module - Databricks Workspace Terraform Module

This repo contains a module to deploy a Databricks workspace to a PrivateLink enabled Databricks account which uses customer-managed VPCs.

## Example Usage
```
 module "databricks_workspace" {
    source = "git::git::https://github.com/UKHomeOffice/databricks-workspace-tf-module.git?ref=main"

    vpc_id                      = "vpc-xxxxxxxxxxxxxxxxx"
    vpc_cidr_range              = "10.0.0.0/18"
    private_subnets_cidr        = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
    sg_egress_ports             = [443, 2443, 5432, 6666, 8443, 8444, 8445, 8446, 8447, 8448, 8449, 8450, 8451]
    databricks_scc_vpce_id      = "vpce-xxxxxxxxxxxxxxxx"
    databricks_rest_vpce_id     = "vpce-xxxxxxxxxxxxxxxx"

    databricks_workspace_storage_key_id   = "xxxxxxxxxxxxxxxx"
    databricks_managed_services_key_id    = "xxxxxxxxxxxxxxxx"
    databricks_private_access_settings_id = "xxxxxxxxxxxxxxxx"

    resource_prefix             = "dsa-databricks-"
    tags                        = local.tags
 }
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.24.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.24.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | ~> 1.84 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cross_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_security_group.sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_s3_bucket.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_versioning.root_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_public_access_block.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_policy.root_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials) | resource |
| [databricks_mws_storage_configurations.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_storage_configurations) | resource |
| [databricks_mws_networks.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_workspaces.workspace](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces) | resource |
| [databricks_metastore_assignment.default_metastore](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |
| [databricks_compliance_security_profile_workspace_setting.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/compliance_security_profile_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC in which the Databricks workspace will be deployed | `string` | n/a | yes |
| <a name="input_vpc_cidr_range"></a> [vpc\_cidr\_range](#input\_vpc\_cidr\_range) | The CIDR range of the VPC in which the workspace will be deployed | `string` | n/a | yes |
| <a name="input_private_subnets_cidr"></a> [private\_subnets\_cidr](#input\_private\_subnets\_cidr) | A list of CIDR ranges for the 3 x private subnets used to host Databricks classic compute clusters | `list(string)` | `[]` | no |
| <a name="input_sg_egress_ports"></a> [sg\_egress\_ports](#input\_sg\_egress\_ports) | A list of ports to allow outbound network traffic from the classic compute clusters SG | `list(string)` | `[]` | no |
| <a name="input_databricks_scc_vpce_id"></a> [databricks\_scc\_vpce\_id](#input\_databricks\_scc\_vpce\_id) | The ID of the Databricks VPC endpoint registration used for the SCC Relay | `string` | n/a | yes |
| <a name="input_databricks_rest_vpce_id"></a> [databricks\_scc\_vpce\_id](#input\_databricks\_rest\_vpce\_id) | The ID of the Databricks VPC endpoint registration used for REST | `string` | n/a | yes |
| <a name="input_databricks_workspace_storage_key_id"></a> [databricks\_workspace\_storage\_key\_id](#input\_databricks\_workspace\_storage\_key\_id) | The ID of the Databricks encryption key used for workspace storage encryption | `string` | n/a | yes |
| <a name="input_databricks_managed_services_key_id"></a> [databricks\_managed\_services\_key\_id](#input\_databricks\_managed\_services\_key\_id) | The ID of the Databricks encryption key used for managed services encryption | `string` | n/a | yes |
| <a name="input_databricks_private_access_settings_id"></a> [databricks\_private\_access\_settings\_id](#input\_databricks\_private\_access\_settings\_id) | The ID of the Databricks private access settings (PAS) used for frontend PrivateLink to the workspace | `string` | n/a | yes |
| <a name="input_resource_prefix"></a> [vpc\_id](#input\_resource\_prefix) | The prefix to use when applying names to resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_workspace_url"></a> [workspace\_url](#output\_workspace\_url) | n/a |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | n/a |
<!-- END_TF_DOCS -->
