##############################################################################
# App ID
##############################################################################

module "appid" {
  source            = "github.com/Cloud-Schematics/appid-module"
  region            = var.region
  prefix            = var.prefix
  tags              = var.tags
  use_data          = var.appid_use_data
  appid_name        = var.appid_name
  resource_group_id = var.appid_use_data == true ? var.appid_resource_group_id : var.resource_group_id
}

##############################################################################

##############################################################################
# App ID resource key
##############################################################################

resource "ibm_resource_key" "appid_key" {
  name                 = "${var.prefix}-teleport-app-id-key"
  resource_instance_id = module.appid.guid
  role                 = "Writer"
  tags                 = var.tags
}

##############################################################################

##############################################################################
# Teleport Config
##############################################################################

module "teleport_config" {
  source = "./teleport_config"
  # prevent null values from forcing a string template to fail
  TELEPORT_LICENSE          = var.teleport_license == null ? "null" : var.teleport_license
  HTTPS_CERT                = var.https_cert == null ? "null" : var.https_cert
  HTTPS_KEY                 = var.https_key == null ? "null" : var.https_key
  HOSTNAME                  = var.teleport_hostname == null ? "null" : var.teleport_hostname
  DOMAIN                    = var.teleport_domain == null ? "null" : var.teleport_domain
  TELEPORT_VERSION          = var.teleport_version == null ? "null" : var.teleport_version
  MESSAGE_OF_THE_DAY        = var.message_of_the_day == null ? "null" : var.message_of_the_day
  CLAIM_TO_ROLES            = var.claims_to_roles
  COS_BUCKET                = ibm_cos_bucket.bucket.bucket_name
  COS_BUCKET_ENDPOINT       = ibm_cos_bucket.bucket.s3_endpoint_public
  HMAC_ACCESS_KEY_ID        = ibm_resource_key.key.credentials["cos_hmac_keys.access_key_id"]
  HMAC_SECRET_ACCESS_KEY_ID = ibm_resource_key.key.credentials["cos_hmac_keys.secret_access_key"]
  APPID_CLIENT_ID           = ibm_resource_key.appid_key.credentials["clientId"]
  APPID_CLIENT_SECRET       = ibm_resource_key.appid_key.credentials["secret"]
  APPID_ISSUER_URL          = ibm_resource_key.appid_key.credentials["oauthServerUrl"]
}

##############################################################################

##############################################################################
# Get image
##############################################################################

data "ibm_is_image" "image" {
  name = var.image_name
}

##############################################################################

##############################################################################
# Create VSI Deployment
##############################################################################

module "teleport_vsi" {
  source                     = "github.com/Cloud-Schematics/icse-vsi-deployment"
  prefix                     = var.prefix
  tags                       = var.tags
  image_id                   = true
  image_name                 = data.ibm_is_image.image.id # Prevent force deletion when scaling
  vsi_per_subnet             = 1
  profile                    = var.profile
  resource_group_id          = var.resource_group_id
  vpc_id                     = var.vpc_id
  subnet_zone_list           = var.subnet_zone_list
  deployment_name            = "teleport"
  boot_volume_encryption_key = var.boot_volume_encryption_key
  primary_security_group_ids = var.primary_security_group_ids
  ssh_key_ids                = var.ssh_key_ids
  add_floating_ip            = var.add_floating_ip
  user_data                  = module.teleport_config.cloud_init
}

##############################################################################

##############################################################################
# App ID Redirect URLs
##############################################################################

locals {
  appid_redirect_urls = [
    for subnet in range(length(var.subnet_zone_list)) :
    "https://${var.prefix}-teleport-vsi-${subnet}.${var.teleport_domain}:3080/v1/webapi/oidc/callback"
  ]
}

resource "ibm_appid_redirect_urls" "urls" {
  tenant_id = module.appid.guid
  urls      = local.appid_redirect_urls
}

##############################################################################