######## DNAC Site Hierarchy

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