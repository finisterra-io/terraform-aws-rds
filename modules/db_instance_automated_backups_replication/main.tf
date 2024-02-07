resource "aws_db_instance_automated_backups_replication" "this" {
  count = var.create ? 1 : 0

  source_db_instance_arn = var.source_db_instance_arn
  kms_key_id             = var.kms_key_alias != null ? data.aws_kms_key.kms[0].arn : var.kms_key_id
  pre_signed_url         = var.pre_signed_url
  retention_period       = var.retention_period

}
