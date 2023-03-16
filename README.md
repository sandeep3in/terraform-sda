# Deploying Cisco SDA with Terafform

This use case demonstrates how to automate the most time consuming and repetative tasks when deploying Cisco SDA.

 It is assumed that these tasks below have been manualy configured on DNAC
 as these are most of the time only need to be configured once:

* ISE is already integrated with DNAC
* Global Network Settings like AAA/TACACS/DHCP/DNS/NTP
* Device credentials are configured on DNAC
* Virtual Networks and SGT's are configured
* Device has loaded initial minimal configuration needed for DNAC discovery
* Tested with DNAC 2.2.3.5

> * provider version 1.0.8-beta and 1.0.9-beta are broken. Version 1.0.10-beta is fixed again. 

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/96>

## Initial Configuration

File: values.tfvars

```ruby
area = "South Africa"
building = "Cape_Town"
floor = "Ground Floor"
VN = "CORP_VN"
DHCP_Server = "1.1.1.1"
DNS_Server = "1.1.1.1"
IP_Pool_Global = "66.66.0.0/16"
bulding_address = "63 Victoria Rd, Camps Bay, Cape Town, 8040, South Africa"
floor_hight = "10.0"
floor_lenght = "200.0"
floor_width = "400.0"
building_ipv4_subnet = "66.66.1.0"
building_ipv4_gate_way = "66.66.1.1"
building_ipv4_INFRA_VN_subnet = "66.66.5.0"
building_ipv4_INFRA_VN_gate_way = "66.66.5.1"
bulding_Border_HandOff = "66.66.254.0"
device_ip_address = "172.16.100.94"
```

> * TODO - create excel where these input variables can be entered and converted to .tfvarf file

File: variables.tf

```ruby
variable "area" {
  type = string
  }

variable "building" {   
  type = string
  }

variable "floor" {    
  type = string
  }

variable "VN" {
  type = string
  description = "VRF/VN name"
  }

variable "DHCP_Server" {
  type = string
  description = "Global_DHCP_Server"
  }

variable "DNS_Server" {
  type = string
  description = "Global_DNS_Server"
  }

variable "IP_Pool_Global" {
  type = string
  description = "Global IP Pool"
  }
  
variable "bulding_address" {
  type = string
  description = "Physical Bulding address i.e. city,street etc. "
  }

variable "floor_hight" {
  type = string
  description = "in meters"
  }

variable "floor_width" {
  type = string
  description = "in meters"
  }
variable "floor_lenght" {
  type = string
  description = "in meters"
  }
variable "building_ipv4_subnet" {
  type = string
  description = "ipv4 subnet for vn in a building"
  }
variable "building_ipv4_gate_way" {
  type = string
  description = "subnet gateway"
  }
variable "building_ipv4_INFRA_VN_subnet" {
  type = string
  description = "INFRA_VN AP Pool"  
  }
variable "building_ipv4_INFRA_VN_gate_way" {
  type = string
  description = "INFRA_VN gateway"
  }
variable "bulding_Border_HandOff" {
  type = string
  description = "WAN Automation border handoff"
  }
variable "device_ip_address" {
  type = string
  description = "IP address od device to be discovered"
}
```

File: provider.tf

```ruby
terraform {
  required_providers {
    dnacenter = {
      source = "cisco-en-programmability/dnacenter"
      version = "1.0.7-beta"
    }
  }
}

provider "dnacenter" {
  username = "username"
  password = "password"
  base_url = "https://dnac-ip-address"
  debug = "true"
  ssl_verify = "false"
}                               
```

## Configuration Steps Automated with Terraform

> * run terraform and include the .tfvars file as input for variables

```ruby
terraform apply -var-file="values.tfvars" -auto-approve
```

> * Terraform automatically loads a number of variable definitions files if named the following way:
> * Files named exactly terraform.tfvars or terraform.tfvars.json.
> * Any files with names ending in .auto.tfvars or .auto.tfvars.json.
> * rename the file values.tfvars to values.auto.tfvars

### Step 1. Add DNAC Site hierarchy

![image info](img/dnac-hierarchy.png)

```ruby
resource "dnacenter_site" "area" {
  provider = dnacenter
  parameters {
    site {
      area {
        name = var.area
        parent_name = "Global"
      }
    }
    type = "area"
  }
}
resource "dnacenter_site" "building" {
  provider = dnacenter
  depends_on = [ dnacenter_site.area ]
  parameters {
    site {
      building {
        name = var.building
        address     = var.bulding_address
        parent_name = "Global/${var.area}"
        # Optional latitude and longitude
        latitude    = -33.9508898420
        longitude   = 18.377273855178373
      }
    }
    type = "building"
  }
}
 resource "dnacenter_site" "floor" {
   provider = dnacenter
   depends_on = [ dnacenter_site.building ]
   parameters {
    site {
      floor {
        height       = var.floor_hight
        length       = var.floor_lenght
        width        = var.floor_width
        name = var.floor
        parent_name  = "Global/${var.area}/${var.building}"
        rf_model     = "Cubes And Walled Offices"
      }
    }
    type = "floor"
  }
}

output "_001_Created_Area" {
  value = dnacenter_site.area.item.0.site_name_hierarchy
}

output "_002_Created_Building" {
  value = dnacenter_site.building.item.0.site_name_hierarchy
}

output "_003_Created_floor" {
  value = dnacenter_site.floor.item.0.site_name_hierarchy
}
```

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/64>



#### Issue resolution reference: 

### Step 2. Reserve IP Pools per building

![image info](img/dnac_ip_pool_reservation.png)

#### Create Global IP Pool - Optional

```ruby
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
```

#### IP Pool reservation for each VN in a site

```ruby
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
```

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/70>

### Step 3. Add site to SDA Fabric

![image info](img/fabric_site.png)

```ruby
############ Add site to SDA Fabric


resource "dnacenter_sda_fabric_site" "SDA_Fabric" {
  provider = dnacenter
  depends_on = [ dnacenter_site.building ]
  parameters {

    fabric_name         = "Default LAN Fabric"
    site_name_hierarchy = "Global/${var.area}/${var.building}"
  }
}
output "_008_Added_Site_To_SDA_Fabric" {
#  value = dnacenter_sda_fabric_site.SDA_Fabric.item.0.site_name_hierarchy
 value = dnacenter_sda_fabric_site.SDA_Fabric.item.0.status
}
```

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/61>

### Step 4. Configure SDA Fabric Authentication Template

![image info](img/fabric_auth_template.png)

```ruby
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
```

### Step 5. Add Virtual Networks in SDA Fabric

![image info](img/add_vn_in_sda.png)

```ruby
############## Add VN in SDA Fabric
resource "dnacenter_sda_virtual_network" "VN" {
  provider = dnacenter
  depends_on = [ dnacenter_sda_fabric_authentication_profile.Fabric_Auth ]

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
  depends_on = [ dnacenter_sda_virtual_network.VN ]
# depends_on needed because DNAC rate limits this API
# For BAPI: Add VN in SDA Fabric, DNACP Runtime is at maximum allowed concurrent BAPI executions: 1"

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
```

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/65>

### Step 6. Add IP Pool to SDA Virtual Network

![image info](img/add_ip_pool_in_sda.png)

```ruby

######### add ip pool to SDA Virtual Network
resource "dnacenter_sda_virtual_network_ip_pool" "Fabric_IP_Pool" {
  provider = dnacenter
  depends_on = [ dnacenter_sda_virtual_network.VN]

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
  depends_on = [ dnacenter_sda_virtual_network.INFRA_VN ]

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
```

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/67>

### Step 7. Device Discovery

![image info](img/device_descovery.png)

```ruby
resource "dnacenter_discovery" "device" {
  provider = dnacenter
#  depends_on = [ dnacenter_sda_virtual_network_ip_pool.Fabric_IP_Pool ]
  parameters {

#    attribute_info            = "string"
#    cdp_level                 = 1
#    device_ids                = "string"
#    discovery_condition       = "string"
#    discovery_status          = "string"
    discovery_type            = "SINGLE"
# Type of Discovery. 'SINGLE', 'RANGE', 'MULTI RANGE', 'CDP', 'LLDP'
    enable_password_list      = ["C!sco123"]
#    global_credential_id_list = ["string"]
# http - removed because itsnot applicable to switches
#    id                      = "string"
    ip_address_list         = var.device_ip_address
# IP Address of devices to be discovered. Ex: '172.30.0.1' for SINGLE, CDP and LLDP; '72.30.0.1-172.30.0.4' for RANGE; '72.30.0.1-172.30.0.4,172.31.0.1-172.31.0.4' for MULTI RANGE
#    ip_filter_list          = ["string"]
    is_auto_cdp             = "false"
#    lldp_level              = 1
    name                    = "Site3Border"
    netconf_port            = "830"
    num_devices             = 1
#    parent_discovery_id     = "string"
    password_list           = ["C!sco123"]
    preferred_mgmt_ipmethod = "UseLoopBack"
# Preferred Management IP Method.'None' or 'UseLoopBack'. Default is 'None'
    protocol_order          = "ssh"
    retry                   = 3
    retry_count             = 1
#    snmp_auth_passphrase    = "C!sco123"
#    snmp_auth_protocol      = "sha"
#    snmp_mode               = "string"
#    snmp_priv_passphrase    = "C!sco123"
#    snmp_priv_protocol      = "aes128"
    snmp_ro_community       = "C!sco123"
    snmp_ro_community_desc  = "DNAC-SNMP-Read"
# From DNAC global credentials Name / Description
    snmp_rw_community       = "C!sco123Write"
    snmp_rw_community_desc  = "DNAC-SNMP-Write"
# From DNAC global credentials Name / Description
#    snmp_user_name          = "dnacsnmpv3"
    snmp_version            = "v2"
    time_out                = 1
    timeout                 = 5
    update_mgmt_ip          = "false"
    user_name_list          = ["dnac"]
  }
}

output "_014_Device_Discovery_Name" {
  value = dnacenter_discovery.device.item.0.name
#  sensitive = true
# added becaue of the passwords 
}

output "_015_Device_Discovery_Status" {
    value = dnacenter_discovery.device.item.0.discovery_condition  
    }
```

***device will apear in inventory but needs time to sync with DNAC***

![image info](img/device_inventory_1.png)

***after a while device is Managed with DNAC***

![image info](img/device_inventory_2.png)

**For Now I run device discovery as a seperate task from a different folder for now untill I can include device sync status as part of the workflow.**

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/76>

### Step 8. Add device to Site and provision  

```ruby
resource "dnacenter_sda_provision_device" "provision" {
  depends_on = [dnacenter_discovery.device]
  provider = dnacenter
  parameters {

    device_management_ip_address = var.device_ip_address
    site_name_hierarchy          = "Global/${var.area}/${var.building}"
  }
}

output "_016_Device_Provision_to_Site" {
  value = dnacenter_sda_provision_device.provision.item.0.status
}
```

Device Provisioning started:

![image info](img/device_provision_1.png)

Device Provisinoning/Configuration started:

![image info](img/device_provision_2.png)

Device Provisioning completed:

![image info](img/device_provision_3.png)

**For now I run device provision as a seperate task from a different folder for now untill I can include device sync status as part of the workflow.**

If device provisioning fails specially in the test or lab when the steps are executed multiple times make sure there are no "AAA" config left over on the device.

![image info](img/provison_failed.png)

### Step 9. Add device to fabric (Border,Control Plane, Edge)

After the device is provisioned it will show in Fabric Site:

![image info](img/sda_device_0.png)

```ruby
resource "dnacenter_sda_fabric_border_device" "sda_device" {
  provider = dnacenter
 # depends_on = [ dnacenter_sda_provision_device.provision ]
  parameters {
	payload {
    border_session_type                = "EXTERNAL"
    border_with_external_connectivity  = "true"
    connected_to_internet              = "false"
# relevant to SDA-Transit only  
    device_management_ip_address       = var.device_ip_address
    device_role                        = ["Border_Node", "Control_Plane_Node","Edge_Node"]
    external_connectivity_ip_pool_name = "${var.building}_Border_HandOff"
    external_connectivity_settings {

      external_autonomou_system_number = "65555"
      interface_description            = "WAN interface"
      interface_name                   = "GigabitEthernet1/0/3"

#      l2_handoff {
#
#          virtual_network_name = "string"
#          vlan_name            = "string"
#        }
# Border L2 hand-off is not supported on a device that is configured as an edge.
        
      l3_handoff {

        virtual_network {

          virtual_network_name = var.VN
          vlan_id              = "111"
        }
      }
    }
    external_domain_routing_protocol_name = "BGP"
    internal_autonomou_system_number      = "65003"
#    sda_transit_network_name              = ""
    site_name_hierarchy                   = "Global/${var.area}/${var.building}"
  	}
  }
}

output "_017_Provision_SDA_Device" {
#  value = dnacenter_sda_fabric_border_device.sda_device.item.0
value = "Device_added_to_SDA_Fabric"
}


/* It takes time to remove VRF on IOS-XE so you cannot destroy and apply this consecutivly because you'll get a error like this:
"description": "Conflicting configuration present on device. 
VRF with route distinguisher 4099 is already configured on device Site3FIAB.sdalab.internal. 
Please remove the VRF with the route distinguisher or change the route distinguisher on the device, resync and retry the operation."
*/
```

![image info](img/sda_device_1.png)

![image info](img/sda_device_2.png)

![image info](img/sda_device_3.png)

**Note:**
> It takes time to remove VRF on IOS-XE so you cannot destroy and apply this consecutivly because you'll get a error like this:
> "description": "Conflicting configuration present on device.
> VRF with route distinguisher 4099 is already configured on device Site3FIAB.sdalab.internal.
> Please remove the VRF with the route distinguisher or change the route distinguisher on the device, resync and retry the operation."

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/68>

### Step 10. Display Border HandOff Information



```ruby
data "dnacenter_sda_fabric_border_device" "border" {
#  depends_on = [ dnacenter_sda_fabric_border_device.sda_device ]
  provider                     = dnacenter
  device_management_ip_address = var.device_ip_address
}

output "_018_SDA_Fabric_Device_Provisioned_details" {
  description = "True"
  value = "True"
}


output "_019_Local_Handoff_IP_address" {
  description = "Local Handoff IP address"
  value = data.dnacenter_sda_fabric_border_device.border.item.0.device_settings.0.ext_connectivity_settings.0.l3_handoff.0.local_ip_address
}

output "_020_Remote_Handoff_IP_address" {
  description = "Remote Handoff IP address"
  value = data.dnacenter_sda_fabric_border_device.border.item.0.device_settings.0.ext_connectivity_settings.0.l3_handoff.0.remote_ip_address
}

output "_021_Vlan_num" {
  description = "Vlan num"
  value = data.dnacenter_sda_fabric_border_device.border.item.0.device_settings.0.ext_connectivity_settings.0.l3_handoff.0.vlan_id
}                                               
```

Ouputs:

```ruby
_018_SDA_Fabric_Device_Provisioned_details = "True"
_019_Local_Handoff_IP_address = "66.66.254.1/30"
_020_Remote_Handoff_IP_address = "66.66.254.2/30"
_021_Vlan_num = 111
```

#### Issue resolution reference: <https://github.com/cisco-en-programmability/terraform-provider-dnacenter/issues/77>

## Optional

### Create Virtual Network

```ruby
resource "dnacenter_sda_virtual_network_v2" "example" {
  provider = dnacenter
  parameters {

#    is_guest_virtual_network = "false"
# its not needed anymore. This option has been removed from DNAC configuration.
    scalable_group_names     = ["BYOD"]
    virtual_network_name     = "IoT"
  }
}

output "dnacenter_sda_virtual_network_v2_example" {
  value = dnacenter_sda_virtual_network_v2.example
}
```

## Reference

<https://github.com/rickbauer9482/terraform-dnac-network-hierarchy>

<https://registry.terraform.io/providers/cisco-en-programmability/dnacenter/>

<https://github.com/cisco-en-programmability/terraform-provider-dnacenter>

<https://developer.cisco.com/codeexchange/github/repo/rickbauer9482/terraform-dnac-network-hierarchy>
