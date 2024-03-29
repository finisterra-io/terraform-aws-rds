# db_instance_automated_backups_replication

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.67 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.67 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance_automated_backups_replication.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance_automated_backups_replication) | resource |
| [aws_kms_key.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create this resource or not? | `bool` | `true` | no |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | The KMS encryption key alias in the destination AWS Region | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS encryption key ARN in the destination AWS Region | `string` | `null` | no |
| <a name="input_pre_signed_url"></a> [pre\_signed\_url](#input\_pre\_signed\_url) | A URL that contains a Signature Version 4 signed request for the StartDBInstanceAutomatedBackupsReplication action to be called in the AWS Region of the source DB instance | `string` | `null` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | The retention period for the replicated automated backups | `number` | `7` | no |
| <a name="input_source_db_instance_arn"></a> [source\_db\_instance\_arn](#input\_source\_db\_instance\_arn) | The ARN of the source DB instance for the replicated automated backups | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The automated backups replication id |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
