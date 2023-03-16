######### add ip pool to SDA Virtual Network
resource "dnacenter_sda_virtual_network_ip_pool" "Fabric_IP_Pool" {
  provider = dnacenter
  depends_on = [ dnacenter_sda_virtual_network.VN ]

  parameters {

    auto_generate_vlan_name  = "false"
    ip_pool_name             = "${var.building}_${var.VN}"
    is_common_pool           = "false"
    is_ip_directed_broadcast = "false"
    is_l2_flooding_enabled   = "false"
    is_layer2_only           = "false"
    is_this_critical_pool    = "false"
    is_wireless_pool         = "false"
#    pool_type                = "string"
#    scalable_group_name      = "string"
    site_name_hierarchy      = "Global/${var.area}/${var.building}"
    traffic_type             = "Data"
    virtual_network_name     = "${var.VN}"
    vlan_id                  = "3200"
# Vlan Id (e.g.,2-4096 except for reserved VLANs (1002-1005, 2046, 4095))
    vlan_name                = "${var.VN}"
  }
}

output "_012_Add_IP_Pool_in_Fabric" {
  value = dnacenter_sda_virtual_network_ip_pool.Fabric_IP_Pool.item.0.ip_pool_name
}
########## add ip pool for INFRA_VN to SDA Virtual Network
resource "dnacenter_sda_virtual_network_ip_pool" "INFRA_VN" {
  provider = dnacenter
  depends_on = [ dnacenter_sda_virtual_network.INFRA_VN, dnacenter_sda_virtual_network_ip_pool.Fabric_IP_Pool ]

  parameters {

    auto_generate_vlan_name  = "false"
    ip_pool_name             = "${var.building}_INFRA_VN"
#    is_common_pool           = "false"
#    is_ip_directed_broadcast = "false"
#    is_l2_flooding_enabled   = "false"
#   is_layer2_only           = "false"
#    is_this_critical_pool    = "false"
#    is_wireless_pool         = "false"
    pool_type                = "AP"
#    scalable_group_name      = "string"
    site_name_hierarchy      = "Global/${var.area}/${var.building}"
#    traffic_type             = "Data"
    virtual_network_name     = "INFRA_VN"
    vlan_id                  = "1024"
# Vlan Id (e.g.,2-4096 except for reserved VLANs (1002-1005, 2046, 4095))
    vlan_name                = "INFRA_VN"
  }
}

output "_013_Add_IP_Pool_for_INFRA_VN_in_Fabric" {
  value = dnacenter_sda_virtual_network_ip_pool.INFRA_VN.item.0.ip_pool_name
}