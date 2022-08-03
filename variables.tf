##############################################################################
# Account Variables
##############################################################################

variable "region" {
  description = "The region to which to deploy the VPC"
  type        = string
}

variable "prefix" {
  description = "The prefix that you would like to prepend to your resources"
  type        = string
}

variable "tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

variable "resource_group_id" {
  description = "Resource group ID for App ID instance"
  type        = string
  default     = null
}

##############################################################################

##############################################################################
# App ID Variables
##############################################################################

variable "appid_use_data" {
  description = "Get App ID information from data."
  type        = bool
  default     = false
}

variable "appid_name" {
  description = "App ID name. Use only if `use_data` is true."
  type        = string
  default     = null
}

variable "appid_resource_group_id" {
  description = "App ID resource group. Use only if `use_data` is true."
  type        = string
  default     = null
}

##############################################################################

##############################################################################
# Object Storage Variables
##############################################################################

variable "cos_suffix" {
  description = "Random suffix appended to cos buckets"
  type        = string
  default     = ""
}

variable "cos_id" {
  description = "ID of the COS instance where a bucket will be created"
  type        = string
}

variable "bucket_encryption_key_id" {
  description = "ID of the encryption key to use for the teleport cos bucket"
  type        = string
  default     = null
}

variable "bucket_config" {
  description = "Configuration for teleport object storage bucket"
  type = object({
    name                  = string
    storage_class         = string
    endpoint_type         = string
    force_delete          = bool
    single_site_location  = optional(string)
    region_location       = optional(string)
    cross_region_location = optional(string)
    allowed_ip            = optional(list(string))
    hard_quota            = optional(number)
    archive_rule = optional(object({
      days    = number
      enable  = bool
      rule_id = optional(string)
      type    = string
    }))
    activity_tracking = optional(object({
      activity_tracker_crn = string
      read_data_events     = bool
      write_data_events    = bool
    }))
    metrics_monitoring = optional(object({
      metrics_monitoring_crn  = string
      request_metrics_enabled = optional(bool)
      usage_metrics_enabled   = optional(bool)
    }))
  })
  default = {
    name          = "teleport-bucket"
    storage_class = "standard"
    force_delete  = "true"
    endpoint_type = "public"
  }
}

##############################################################################

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_id" {
  description = "ID of the VPC where VSI will be provisioned"
  type        = string
}

variable "subnet_zone_list" {
  description = "List of subnets where the VSI deployment primary network interfaces will be created. This is intended to be an output from the ICSE Subnet Module or templates using it."
  type = list(
    object({
      name = string
      id   = string
      zone = string
      cidr = string
    })
  )
}

variable "ssh_key_ids" {
  description = "List of SSH Key Ids. At least one SSH key must be provided"
  type        = list(string)

  validation {
    error_message = "To provision VSI at least one VPC SSH Ket must be provided."
    condition     = length(var.ssh_key_ids) > 0
  }
}

##############################################################################

##############################################################################
# VSI Variables
##############################################################################

variable "profile" {
  description = "Machine type for Teleport VSI instances. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles."
  type        = string
  default     = "cx2-4x8"
}

variable "image_name" {
  description = "Teleport VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see availabled images."
  type        = string
  default     = "ibm-ubuntu-18-04-6-minimal-amd64-2"
}

variable "primary_security_group_ids" {
  description = "(Optional) List of security group ids to add to the primary network interface of each virtual server. Using an empty list will assign the default VPC security group."
  type        = list(string)
  default     = null

  validation {
    error_message = "Primary security group IDs should be either `null` or contain at least one security group."
    condition = (
      var.primary_security_group_ids == null
      ? true
      : length(var.primary_security_group_ids) > 0
    )
  }
}

variable "primary_interface_security_group" {
  description = "Object describing a security group to create for the primary interface,"
  type = object({
    create = bool
    rules = list(
      object({
        name      = string
        direction = string
        remote    = string
        tcp = optional(
          object({
            port_max = number
            port_min = number
          })
        )
        udp = optional(
          object({
            port_max = number
            port_min = number
          })
        )
        icmp = optional(
          object({
            type = number
            code = number
          })
        )
      })
    )
  })
  default = {
    create = false
    rules  = []
  }
}

variable "boot_volume_encryption_key" {
  description = "(Optional) Boot volume encryption key to use for each server in the deployment."
  type        = string
  default     = null
}

variable "add_floating_ip" {
  description = "Add a floating IP to the primary network interface for each server in the deployment."
  type        = bool
  default     = false
}

##############################################################################

##############################################################################
# Teleport Configuration Variables
##############################################################################

variable "teleport_license" {
  description = "The contents of the PEM license file"
  type        = string
  default     = null
}

variable "https_cert" {
  description = "The https certificate used by bastion host for teleport"
  type        = string
  default     = null
}

variable "https_key" {
  description = "The https private key used by bastion host for teleport"
  type        = string
  default     = null
}
variable "teleport_hostname" {
  description = "The name of the instance or bastion host"
  type        = string
  default     = null
}

variable "teleport_domain" {
  description = "The domain of the bastion host"
  type        = string
  default     = null
}

variable "teleport_version" {
  description = "Version of Teleport Enterprise to use"
  type        = string
  default     = "7.1.0"
}

variable "message_of_the_day" {
  description = "Banner message that is exposed to the user at authentication time"
  type        = string
  default     = null
}

variable "claims_to_roles" {
  description = "A list of maps that contain the user email and the role you want to associate with them"
  type = list(
    object({
      email = string
      roles = list(string)
    })
  )
  default = []
}

##############################################################################