data "aws_kms_key" "kms" {
  count  = var.create && var.kms_key_alias != null ? 1 : 0
  key_id = var.kms_key_alias
}