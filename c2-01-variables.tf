# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "eu-central-1"  
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to create the cluster in (e.g. `vpc-a22222ee`)"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC subnet IDs to place DocumentDB instances in"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the DocumentDB cluster"
}

variable "db_port" {
  type        = number
  default     = 27017
  description = "DocumentDB port"
}

variable "cluster_family" {
  type        = string
  default     = "docdb3.6"
  description = "The family of the DocumentDB cluster parameter group (docdb5.0, docdb4.0, docdb3.6). For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html"
}

variable "cluster_parameters" {
  type = list(object({
    apply_method = string
    name         = string
    value        = string
  }))
  default     = []
  description = "List of DB parameters to apply"
}

variable "cluster_name" {
  type        = string
  default     = "docdb"
  description = "The name of the DocumentDB cluster"
}

variable "master_username" {
  type        = string
  default     = ""
  description = "(Required unless a snapshot_identifier is provided) Username for the master DB user"
}

variable "master_password" {
  type        = string
  default     = ""
  description = "(Required unless a snapshot_identifier is provided) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the DocumentDB Naming Constraints"
}

variable "retention_period" {
  type        = number
  default     = 1
  description = "Number of days to retain backups for"
}

variable "preferred_backup_window" {
  type        = string
  default     = "03:00-05:00"
  description = "Daily time range during which the backups happen"
}

variable "preferred_maintenance_window" {
  type        = string
  default     = "Sun:2:00-Sun:3:00"
  description = "The window to perform maintenance in. Syntax: `ddd:hh24:mi-ddd:hh24:mi`."
}



# variable "final_snapshot_identifier" {
#   type        = string
#   description = "A final snapshot is taken for backup before deleting the cluster. This setting specifies the name for that snapshot, which is set to a lowercase version of the cluster identifier"
#   default     = ""

#   validation {
#     condition     = can(regex("^[a-zA-Z0-9-]+$", var.final_snapshot_identifier))
#     error_message = "The final snapshot identifier must contain only alphanumeric characters and hyphens."
#   }
# }

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted"
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "A value that indicates whether the DB cluster has deletion protection enabled"
  default     = false
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
  default     = true
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB cluster is encrypted"
  default     = true
}

variable "storage_type" {
  type        = string
  description = "The storage type to associate with the DB cluster. Valid values: standard, iopt1"
  default     = "standard"
}

variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot"
}

variable "external_security_group_id_list" {
  type        = list(string)
  default     = []
  description = "List of external security group IDs to attach to the Document DB"
}

variable "engine_db" {
  type        = string
  default     = "docdb"
  description = "The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb`"
}

variable "engine_version" {
  type        = string
  default     = "3.6.0"
  description = "The version number of the database engine to use"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: `audit`, `error`, `general`, `slowquery`"
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to security group"
  type        = map(string)
  default     = {}
}

variable "cluster_size" {
  type        = number
  default     = 3
  description = "Number of DB instances to create in the cluster"
}

# https://docs.aws.amazon.com/documentdb/latest/developerguide/limits.html#suported-instance-types
variable "instance_type" {
  type        = string
  default     = "db.t3.medium"
  description = "The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Specifies whether any minor engine upgrades will be applied automatically to the DB instance during the maintenance window or not"
  default     = false
}

variable "enable_performance_insights" {
  type        = bool
  description = "Specifies whether to enable Performance Insights for the DB Instance."
  default     = false
}

variable "ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance"
  default     = null
}