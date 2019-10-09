output "load_balancer_ip" {
  value = ["${packet_reserved_ip_block.ips.cidr_notation}"]
}
