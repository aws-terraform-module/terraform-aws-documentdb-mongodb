resource "aws_kms_key" "documemtdb" {
  description = "EKS Encryption Key"
  tags        = var.tags
}

resource "aws_docdb_subnet_group" "default" {
  name        = "${var.cluster_name}-subnet-group"
  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

# https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html
resource "aws_docdb_cluster_parameter_group" "default" {
  name        = "${var.cluster_name}-pg-${lower(replace(var.cluster_family, "/[^a-z0-9-]/", ""))}"
  description = "DB cluster parameter group"
  family      = var.cluster_family

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      apply_method = lookup(parameter.value, "apply_method", null)
      name         = parameter.value.name
      value        = parameter.value.value
    }
  }
  tags             = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

resource "random_pet" "master_user_random" {
  count     = var.master_username == "" ? 1 : 0
  length    = 1
  separator = "-"
}

resource "random_password" "master_password_random" {
  count   = var.master_password == "" ? 1 : 0
  length  = 24
  special = false
}

resource "aws_docdb_cluster" "default" {
  cluster_identifier              = var.cluster_name
  master_username                 = var.master_username != "" ? var.master_username : random_pet.master_user_random[0].id
  master_password                 = var.master_password != "" ? var.master_password : random_password.master_password_random[0].result
  backup_retention_period         = var.retention_period
  preferred_backup_window         = var.preferred_backup_window
  preferred_maintenance_window    = var.preferred_maintenance_window
  final_snapshot_identifier       = "${var.cluster_name}-final-snapshot-identifier"
  skip_final_snapshot             = var.skip_final_snapshot
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  storage_encrypted               = var.storage_encrypted
  storage_type                    = var.storage_type
  kms_key_id                      = aws_kms_key.documemtdb.arn
  port                            = var.db_port
  snapshot_identifier             = var.snapshot_identifier
  vpc_security_group_ids          = concat([join("", aws_security_group.default[*].id)], var.external_security_group_id_list)
  db_subnet_group_name            = join("", aws_docdb_subnet_group.default[*].name)
  db_cluster_parameter_group_name = join("", aws_docdb_cluster_parameter_group.default[*].name)
  engine                          = var.engine_db
  engine_version                  = var.engine_version
  allow_major_version_upgrade     = var.allow_major_version_upgrade
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags                            = var.tags
}

resource "aws_docdb_cluster_instance" "default" {
 count                        = var.cluster_size
 identifier                   = "${var.cluster_name}-${count.index + 1}"
 cluster_identifier           = join("", aws_docdb_cluster.default[*].id)
 apply_immediately            = var.apply_immediately
 preferred_maintenance_window = var.preferred_maintenance_window
 instance_class               = var.instance_type
 engine                       = var.engine_db
 auto_minor_version_upgrade   = var.auto_minor_version_upgrade
 enable_performance_insights  = var.enable_performance_insights
 ca_cert_identifier           = var.ca_cert_identifier

}
