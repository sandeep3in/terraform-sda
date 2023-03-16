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