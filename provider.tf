terraform {
  required_providers {
    dnacenter = {
      source = "cisco-en-programmability/dnacenter"
      version = "1.0.10-beta"
    }
  }
}

provider "dnacenter" {
  username = "admin"
  password = "C!sco123"
  base_url = "https://10.50.222.124"
  debug = "true"
  ssl_verify = "false"
}                               
