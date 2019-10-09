# Create loadbalancers
resource "packet_device" "LBs" {
  count            = "${var.loadbalancer_count}"
  project_id       = "${packet_project.LB-HA.id}"
  facilities       = "${var.facilities}"
  plan             = "${var.node_plan}"
  hostname         = "${format("%s-%d","LB", count.index+1)}"
  operating_system = "ubuntu_16_04"
  billing_cycle    = "hourly"
  user_data        = "${data.template_file.LBscript.rendered}"
  network_type     = "hybrid"
}

data "template_file" "LBscript" {
 template = "${file("${path.module}/templates/loadbalancers-setup.sh.tpl")}"
}

data "template_file" "Bird-Conf" {
 count = "${var.loadbalancer_count}"
 template = "${file("${path.module}/templates/bird.conf.tpl")}"
 vars = {
    Elastic_IP="${packet_reserved_ip_block.ips.cidr_notation}"
    Server_Private_IPv4="${packet_device.LBs.*.access_private_ipv4[count.index]}"
 }
}

data "template_file" "Elastic-IP-setup" {
 template = "${file("${path.module}/templates/setup-elastic-IP.sh.tpl")}"
 vars = {
    Elastic_IP="${packet_reserved_ip_block.ips.cidr_notation}"
 }
}

data "template_file" "Haproxy-setup" {
 template = "${file("${path.module}/templates/haproxy-config.cfg.tpl")}"
 vars = {
    Elastic_IP="${packet_reserved_ip_block.ips.cidr_notation}"
 }
}

# Attach second interface of LBs to the VLAN
resource "packet_port_vlan_attachment" "LBs-attach" {
  count     = "${var.loadbalancer_count}"
  device_id = "${packet_device.LBs.*.id[count.index]}"
  port_name = "eth1"
  vlan_vnid = "${packet_vlan.vlan1.vxlan}"
}

# Enable BGP on each LB node
resource "packet_bgp_session" "bgp_test_ipv4" {
  count          = "${var.loadbalancer_count}"
  device_id      = "${packet_device.LBs.*.id[count.index]}"
  address_family = "ipv4"
}


# Setup Elastic IP, Bird, and Haproxy
resource "null_resource" "setup_node" {

  depends_on = [packet_port_vlan_attachment.webservers-attach]

  count = "${var.loadbalancer_count}"

  connection {
    type = "ssh"
    user = "root"
    host = "${element(packet_device.LBs.*.access_public_ipv4, count.index)}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.Bird-Conf.*.rendered, count.index)}}"
    destination = "/tmp/bird-config-file.conf"
  }

  provisioner "file" {
    content     = "${data.template_file.Elastic-IP-setup.rendered}"
    destination = "/tmp/setup-elastic-IP.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.Haproxy-setup.rendered}"
    destination = "/tmp/haproxy-config.cfg"
  }

  provisioner "remote-exec" {
    inline = [
       "chmod +x /tmp/setup-elastic-IP.sh",
       "/tmp/setup-elastic-IP.sh"
    ]

    on_failure = "continue"

    connection {
    type = "ssh"
    user = "root"
    host = "${element(packet_device.LBs.*.access_public_ipv4, count.index)}"
    private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

}


# Setup keepalived on each LB node

data "template_file" "setup-keepalived" {
 template = "${file("${path.module}/templates/setup-keepalived.sh.tpl")}"
}


data "template_file" "keepalived-master" {
 template = "${file("${path.module}/templates/keepalived-config.conf.tpl")}"
 vars = {
    Elastic_IP = "${packet_reserved_ip_block.ips.cidr_notation}"
    Main_Server_Private_IPv4 = "${packet_device.LBs[0].access_private_ipv4}"
    Peer_Server_Private_IPv4 = "${packet_device.LBs[1].access_private_ipv4}"
    Role = "MASTER"
    Priority = "101"
 }
}

resource "null_resource" "setup_keepalived_master" {

   depends_on = [null_resource.setup_node]

   connection {
    type = "ssh"
    user = "root"
    host = "${packet_device.LBs[0].access_public_ipv4}"
    private_key = "${file("~/.ssh/id_rsa")}"
   }

   provisioner "file" {
    content     = "${data.template_file.keepalived-master.rendered}"
    destination = "/tmp/keepalived-config.conf"
   }

   provisioner "file" {
    content     = "${data.template_file.setup-keepalived.rendered}"
    destination = "/tmp/setup-keepalived.sh"
   }

   provisioner "remote-exec" {
    inline = [
       "chmod +x /tmp/setup-keepalived.sh",
       "/tmp/setup-keepalived.sh"
    ]

    on_failure = "continue"

    connection {
    type = "ssh"
    user = "root"
    host = "${packet_device.LBs[0].access_public_ipv4}"
    private_key = "${file("~/.ssh/id_rsa")}"
    }

   }



}


data "template_file" "keepalived-backup" {
 template = "${file("${path.module}/templates/keepalived-config.conf.tpl")}"
 vars = {
    Elastic_IP = "${packet_reserved_ip_block.ips.cidr_notation}"
    Main_Server_Private_IPv4 = "${packet_device.LBs[1].access_private_ipv4}"
    Peer_Server_Private_IPv4 = "${packet_device.LBs[0].access_private_ipv4}"
    Role = "BACKUP"
    Priority = "100"
 }
}

resource "null_resource" "setup_keepalived_backup" {

   depends_on = [null_resource.setup_node]

   connection {
    type = "ssh"
    user = "root"
    host = "${packet_device.LBs[1].access_public_ipv4}"
    private_key = "${file("~/.ssh/id_rsa")}"
   }

   provisioner "file" {
    content     = "${data.template_file.keepalived-backup.rendered}"
    destination = "/tmp/keepalived-config.conf"
   }

   provisioner "file" {
    content     = "${data.template_file.setup-keepalived.rendered}"
    destination = "/tmp/setup-keepalived.sh"
   }

   provisioner "remote-exec" {
    inline = [
       "chmod +x /tmp/setup-keepalived.sh",
       "/tmp/setup-keepalived.sh"
    ]
    
    on_failure = "continue"

    connection {
    type = "ssh"
    user = "root"
    host = "${packet_device.LBs[1].access_public_ipv4}"
    private_key = "${file("~/.ssh/id_rsa")}"
    }

   }



}
