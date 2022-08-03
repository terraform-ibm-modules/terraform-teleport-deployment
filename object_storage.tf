##############################################################################
# Create COS Bucket
##############################################################################

locals {
  suffix = var.cos_suffix == "" ? "" : "-${var.cos_suffix}"
}

resource "ibm_cos_bucket" "bucket" {
  bucket_name           = "${var.prefix}-teleport${local.suffix}"
  resource_instance_id  = var.cos_id
  storage_class         = var.bucket_config.storage_class
  endpoint_type         = var.bucket_config.endpoint_type
  force_delete          = var.bucket_config.force_delete
  single_site_location  = var.bucket_config.single_site_location
  cross_region_location = var.bucket_config.cross_region_location
  allowed_ip            = var.bucket_config.allowed_ip
  hard_quota            = var.bucket_config.hard_quota
  key_protect           = var.bucket_encryption_key_id
  region_location = (
    var.bucket_config.region_location == null
    && var.bucket_config.single_site_location == null
    && var.bucket_config.cross_region_location == null
  ) ? var.region : var.bucket_config.region_location

  dynamic "archive_rule" {
    for_each = (
      var.bucket_config.archive_rule == null
      ? []
      : [var.bucket_config.archive_rule]
    )

    content {
      days    = archive_rule.value.days
      enable  = archive_rule.value.enable
      rule_id = archive_rule.value.rule_id
      type    = archive_rule.value.type
    }
  }

  dynamic "activity_tracking" {
    for_each = (
      var.bucket_config.activity_tracking == null
      ? []
      : [var.bucket_config.activity_tracking]
    )

    content {
      activity_tracker_crn = activity_tracking.value.activity_tracker_crn
      read_data_events     = activity_tracking.value.read_data_events
      write_data_events    = activity_tracking.value.write_data_events
    }
  }

  dynamic "metrics_monitoring" {
    for_each = (
      var.bucket_config.metrics_monitoring == null
      ? []
      : [var.bucket_config.metrics_monitoring]
    )

    content {
      metrics_monitoring_crn  = metrics_monitoring.value.metrics_monitoring_crn
      request_metrics_enabled = metrics_monitoring.value.request_metrics_enabled
      usage_metrics_enabled   = metrics_monitoring.value.usage_metrics_enabled
    }
  }
}

##############################################################################

##############################################################################
# COS Access Key
##############################################################################

resource "ibm_resource_key" "key" {
  name                 = "${var.prefix}-teleport${local.suffix}"
  role                 = "Writer"
  resource_instance_id = var.cos_id
  parameters = {
    HMAC = true
  }
  tags = var.tags
}
##############################################################################