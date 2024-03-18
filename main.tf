locals {
  monitoring_role_name        = var.monitoring_role_use_name_prefix ? null : var.monitoring_role_name
  monitoring_role_name_prefix = var.monitoring_role_use_name_prefix ? "${var.monitoring_role_name}-" : null
}

# Ref. https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html#genref-aws-service-namespaces
data "aws_partition" "current" {}

# nosemgrep
resource "aws_db_instance" "this" {
  count = var.create ? 1 : 0

  identifier = var.identifier

  engine            = var.engine
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_alias != null ? data.aws_kms_key.kms[0].arn : var.kms_key_id
  license_model     = var.license_model

  db_name                             = var.db_name
  username                            = var.username
  password                            = var.manage_master_user_password ? null : var.password
  port                                = var.port
  domain                              = var.domain
  domain_iam_role_name                = var.domain_iam_role_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  custom_iam_instance_profile         = var.custom_iam_instance_profile
  manage_master_user_password         = var.manage_master_user_password ? var.manage_master_user_password : null
  master_user_secret_kms_key_id       = var.manage_master_user_password ? var.master_user_secret_kms_key_id : null

  vpc_security_group_ids = [for sg_id in var.vpc_security_group_ids : sg_id == "default" ? data.aws_security_group.default[0].id : sg_id]
  db_subnet_group_name   = var.db_subnet_group_name
  parameter_group_name   = var.parameter_group_name
  option_group_name      = var.option_group_name
  network_type           = var.network_type

  availability_zone   = var.availability_zone
  multi_az            = var.multi_az
  iops                = var.iops
  storage_throughput  = var.storage_throughput
  publicly_accessible = var.publicly_accessible
  ca_cert_identifier  = var.ca_cert_identifier

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately
  maintenance_window         = var.maintenance_window

  dynamic "blue_green_update" {
    for_each = length(var.blue_green_update) > 0 ? [var.blue_green_update] : []

    content {
      enabled = try(blue_green_update.value.enabled, null)
    }
  }

  snapshot_identifier       = var.snapshot_identifier
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.final_snapshot_identifier

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_kms_key_alias != null ? data.aws_kms_key.performance_insights[0].arn : var.performance_insights_kms_key_id

  replicate_source_db     = var.replicate_source_db
  replica_mode            = var.replica_mode
  backup_retention_period = length(var.blue_green_update) > 0 ? coalesce(var.backup_retention_period, 1) : var.backup_retention_period
  backup_window           = var.backup_window
  max_allocated_storage   = var.max_allocated_storage
  monitoring_interval     = var.monitoring_interval
  monitoring_role_arn     = var.monitoring_interval > 0 ? var.monitoring_role_arn : null

  character_set_name              = var.character_set_name
  nchar_character_set_name        = var.nchar_character_set_name
  timezone                        = var.timezone
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection      = var.deletion_protection
  delete_automated_backups = var.delete_automated_backups

  dynamic "restore_to_point_in_time" {
    for_each = var.restore_to_point_in_time != null ? [var.restore_to_point_in_time] : []

    content {
      restore_time                             = lookup(restore_to_point_in_time.value, "restore_time", null)
      source_db_instance_automated_backups_arn = lookup(restore_to_point_in_time.value, "source_db_instance_automated_backups_arn", null)
      source_db_instance_identifier            = lookup(restore_to_point_in_time.value, "source_db_instance_identifier", null)
      source_dbi_resource_id                   = lookup(restore_to_point_in_time.value, "source_dbi_resource_id", null)
      use_latest_restorable_time               = lookup(restore_to_point_in_time.value, "use_latest_restorable_time", null)
    }
  }

  dynamic "s3_import" {
    for_each = var.s3_import != null ? [var.s3_import] : []

    content {
      source_engine         = "mysql"
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = s3_import.value.ingestion_role
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [apply_immediately, skip_final_snapshot]
  }

}

################################################################################
# Enhanced monitoring
################################################################################

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  name                 = local.monitoring_role_name
  name_prefix          = local.monitoring_role_name_prefix
  assume_role_policy   = data.aws_iam_policy_document.enhanced_monitoring.json
  description          = var.monitoring_role_description
  permissions_boundary = var.monitoring_role_permissions_boundary

  tags = var.monitoring_role_tags
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count = var.create_monitoring_role ? 1 : 0

  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
