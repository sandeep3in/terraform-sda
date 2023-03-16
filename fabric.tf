############ Add site to SDA Fabric

resource "dnacenter_sda_fabric_site" "SDA_Fabric" {
  provider = dnacenter
  depends_on = [ dnacenter_site.building, dnacenter_reserve_ip_subpool.VN ]
  parameters {

    fabric_name         = "Default LAN Fabric"
    site_name_hierarchy = "Global/${var.area}/${var.building}"
  }
}
output "_008_Added_Site_To_SDA_Fabric" {
#  value = dnacenter_sda_fabric_site.SDA_Fabric.item.0.site_name_hierarchy
 value = dnacenter_sda_fabric_site.SDA_Fabric.item.0.status
}


############ SDA Fabric set Authentication Template

resource "dnacenter_sda_fabric_authentication_profile" "Fabric_Auth" {
  provider = dnacenter
  depends_on = [ dnacenter_sda_fabric_site.SDA_Fabric ]

  parameters {
    payload {

    authenticate_template_name    = "Closed Authentication"
#    authentication_order          = "Dot1x"
#    dot1x_to_mab_fallback_timeout = "21"
#    number_of_hosts               = "Unlimited"
    site_name_hierarchy           = "Global/${var.area}/${var.building}"
#    wake_on_lan                   = "false"
    }
  }
}

output "_009_SDA_Fabric_Authentication" {
  value = dnacenter_sda_fabric_authentication_profile.Fabric_Auth.item.0.authenticate_template_name
}