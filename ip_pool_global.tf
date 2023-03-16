#### Create Global Pool

resource "dnacenter_global_pool" "Global" {
  provider = dnacenter
  parameters {

    settings {

      ippool {

        ip_address_space = "IPv4"
        dhcp_server_ips  = ["${var.DHCP_Server}"]
        dns_server_ips   = ["${var.DNS_Server}"]
        ip_pool_cidr     = var.IP_Pool_Global
        ip_pool_name     = "Global_${var.IP_Pool_Global}"
        type             = "Generic"
      }
    }
  }
}  
output "_004_Global_IP_Pool" {
  value = dnacenter_global_pool.Global.id
}
