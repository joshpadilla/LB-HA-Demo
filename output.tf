output "load_balancer_ip" {
  value = ["${metal_reserved_ip_block.ips.cidr_notation}"]
}
