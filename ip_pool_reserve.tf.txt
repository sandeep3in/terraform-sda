### IP Pool reservation for each VN in a site
resource "dnacenter_reserve_ip_subpool" "VN" {
  provider = dnacenter
  depends_on = [ dnacenter_site.building, dnacenter_global_pool.Global ]

  parameters {

    id                 = "string"
    ipv4_dhcp_servers = ["${var.DHCP_Server}"]
    ipv4_dns_servers = ["${var.DNS_Server}"]
    ipv4_gate_way      = var.building_ipv4_gate_way
    ipv4_global_pool   = var.IP_Pool_Global
    ipv4_prefix        = "true"
    ipv4_prefix_length = 24
    ipv4_subnet        = var.building_ipv4_subnet
    name               = "${var.building}_${var.VN}"
    site_id            = dnacenter_site.building.item.0.id
    type               = "Generic"
  }

}


  output "_005_Reserve_ip_subpool_VN" {
# value = dnacenter_reserve_ip_subpool.VN.item.0.ip_pools.0.ip_pool_name
 value = "${var.building}_${var.VN}"
} 


### IP Pool reservation for each VN in a site
resource "dnacenter_reserve_ip_subpool" "INFRA_VN" {
  provider = dnacenter
  depends_on = [ dnacenter_site.building, dnacenter_global_pool.Global ]

  parameters {

    id                 = "string"
    ipv4_dhcp_servers = ["${var.DHCP_Server}"]
    ipv4_dns_servers = ["${var.DNS_Server}"]
    ipv4_gate_way      = var.building_ipv4_INFRA_VN_gate_way
    ipv4_global_pool   = var.IP_Pool_Global
    ipv4_prefix        = "true"
    ipv4_prefix_length = 24
    ipv4_subnet        = var.building_ipv4_INFRA_VN_subnet
    name               = "${var.building}_INFRA_VN"
    site_id            = dnacenter_site.building.item.0.id
    type               = "Generic"
  }
}

output "_006_Reserve_ip_subpool_INFRA_VN" {
  value = dnacenter_reserve_ip_subpool.INFRA_VN.item.0.ip_pools.0.ip_pool_name
} 

### IP Pool reservation for Border WAN HanndOff automation
resource "dnacenter_reserve_ip_subpool" "Border_HandOff" {
  provider = dnacenter
  depends_on = [ dnacenter_site.building, dnacenter_global_pool.Global ]

  parameters {

    id                 = "string"
    ipv4_global_pool   = var.IP_Pool_Global
    ipv4_prefix        = "true"
    ipv4_prefix_length = 24
    ipv4_subnet        = var.bulding_Border_HandOff
    name               = "${var.building}_Border_HandOff"
    site_id            = dnacenter_site.building.item.0.id
    type               = "Generic"
  }
}

output "_007_Reserve_ip_subpool_Border_HandOff" {
  value = dnacenter_reserve_ip_subpool.Border_HandOff.item.0.ip_pools.0.ip_pool_name
} 