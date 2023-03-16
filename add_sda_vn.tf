############## Add VN in SDA Fabric
resource "dnacenter_sda_virtual_network" "VN" {
  provider = dnacenter
  depends_on = [ dnacenter_sda_fabric_authentication_profile.Fabric_Auth, dnacenter_sda_fabric_site.SDA_Fabric  ]

  parameters {
    payload {
      
    site_name_hierarchy  = "Global/${var.area}/${var.building}"
    virtual_network_name = var.VN
    }
  }
}
output "_010_Virtual_Network_CORP_VN_Added_in_Fabric" {
  value = dnacenter_sda_virtual_network.VN.item.0.status
}

############## Add INFRA_N in SDA Fabric
resource "dnacenter_sda_virtual_network" "INFRA_VN" {
  provider = dnacenter
  depends_on = [ dnacenter_sda_virtual_network.VN, dnacenter_sda_fabric_authentication_profile.Fabric_Auth, 
  dnacenter_sda_fabric_site.SDA_Fabric, dnacenter_reserve_ip_subpool.INFRA_VN  ]
# depends_on needed because DNAC rate limits this API
# For BAPI: Add VN in SDA Fabric, DNACP Runtime is at maximum allowed concurrent BAPI executions: 1"
# it could be not relevant if used with for_each 

  parameters {
    payload {
      
    site_name_hierarchy  = "Global/${var.area}/${var.building}"
    virtual_network_name = "INFRA_VN"
    }
  }
}

output "_011_Virtual_Network_INFRA_VN_Added_in_Fabric" {
  value = dnacenter_sda_virtual_network.INFRA_VN.item.0.status
}
