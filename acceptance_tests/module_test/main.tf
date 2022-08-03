##############################################################################
# IBM Cloud Provider
##############################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  ibmcloud_timeout = 60
}

##############################################################################

##############################################################################
# Teleport Module
##############################################################################

module "teleport_deployment" {
  source             = "../../"
  region             = "eu-de"
  prefix             = "at"
  tags               = ["tag1", "tag2"]
  resource_group_id  = "1234"
  appid_use_data     = false
  cos_suffix         = "test"
  cos_id             = "crn:v1:bluemix:public:cloud-object-storage:global:a/cdefe6d99f7ea459aacb25775fb88a33:a805891e-eaf6-4752-900f-851b39f8a212::"
  vpc_id             = "vpc-123"
  ssh_key_ids        = ["sshkey123"]
  teleport_license   = "null"
  https_cert         = "null"
  https_key          = "null"
  teleport_hostname  = "null"
  teleport_domain    = "null"
  teleport_version   = "null"
  message_of_the_day = "null"
  claims_to_roles = [
    {
      email = "test@test.email"
      roles = ["Writer"]
    }
  ]
  subnet_zone_list = [
    {
      name = "subnet-1"
      id   = "subnet-id-1234"
      cidr = "10.10.10.10/24"
      zone = "eu-de-1"
    }
  ]
}

##############################################################################