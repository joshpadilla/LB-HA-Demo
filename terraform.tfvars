metal_auth_token = "EQUINIX_METAL_API_TOKEN"
facilities = ["ewr1"]

# Server type, this demo requires servers with bonded LACP networking (2x 10 Gbps ports).
node_plan = "m1.xlarge.x86"

# These count numbers cannot be changed to other numbers because there needs to be more automation around IP configurations in places such as haproxy configuration files, keeaplived etc.
loadbalancer_count = "2"
webserver_count = "2"

# These are the Private IPs used but these variables aren't used.
gateway_IP = "192.168.1.1"
webserver1_private_IP = "192.168.1.10"
webserver2_private_IP = "192.168.1.11"
