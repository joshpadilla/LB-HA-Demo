# Create user_data tailored for each webserver
data "template_file" "script1" {
  count = "${var.webserver_count}"
  template = "${file("${path.module}/templates/webserver-setup.sh.tpl")}"
  vars = {
    web_private_IP = "${format("%d",count.index+10)}"
    webname = "${format("%s-%d","webserver", count.index+1)}"
  }
}

# Create webservers
resource "metal_device" "webservers" {
  count = "${var.webserver_count}"
  project_id       = "${metal_project.LB-HA.id}"
  facilities       = "${var.facilities}"
  plan             = "${var.node_plan}"
  hostname         = "${format("%s-%d","webserver", count.index+1)}"
  operating_system = "ubuntu_16_04"
  billing_cycle    = "hourly"
  user_data        = "${data.template_file.script1.*.rendered[count.index]}"
  network_type     = "layer2-bonded"
}

# Attach webservers to the VLAN
resource "metal_port_vlan_attachment" "webservers-attach" {
  depends_on = [metal_device.webservers]
  count = "${var.webserver_count}"
  device_id = "${metal_device.webservers.*.id[count.index]}"
  port_name = "bond0"
  vlan_vnid = "${metal_vlan.vlan1.vxlan}"
}
