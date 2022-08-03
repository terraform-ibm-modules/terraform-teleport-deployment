##############################################################################
# App ID Outputs
##############################################################################

output "appid_guid" {
  description = "App ID GUID"
  value       = module.appid.guid
}

output "appid_crn" {
  description = "App ID CRN"
  value       = module.appid.crn
}

output "appid_redirect_urls" {
  description = "List of App ID redirect URLs"
  value       = ibm_appid_redirect_urls.urls
}

##############################################################################

##############################################################################
# VSI Outputs
##############################################################################

output "virtual_servers" {
  description = "List of VSI IDs, Names, Primary IPV4 addresses, floating IPs, and secondary floating IPs"
  value       = module.teleport_vsi.virtual_servers
}

##############################################################################