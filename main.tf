provider "metal" {
  auth_token = "${var.auth_token}"
}

resource "metal_project" "LB-HA" {
  name = "Load-Balancing-HA Demo"

  bgp_config {
    deployment_type = "local"
    asn             = 65000
  }
}

resource "metal_vlan" "vlan1" {
  description = "VLAN in New Jersey"
  facility    = "ewr1"
  project_id  = "${metal_project.LB-HA.id}"
}

resource "metal_reserved_ip_block" "ips" {
  project_id = "${metal_project.LB-HA.id}"
  facility   = "${var.facilities[0]}"
  quantity   = 1
}
