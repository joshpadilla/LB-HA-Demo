filter packetdns {
# IPs to announce (the elastic ip in our case)
# Doesn't have to be /32. Can be lower
if net = ${Elastic_IP} then accept;
}
# your (Private) bond0 IP below here (unique to each LB server)
router id ${Server_Private_IPv4};
protocol direct {
interface "bond0"; # Restrict network interfaces it works with (it's lo in the BGP guide, changed to bond0)
}
protocol kernel {
# learn; # Learn all alien routes from the kernel
persist; # Don't remove routes on bird shutdown
scan time 20; # Scan kernel routing table every 20 seconds
import all; # Default is import all
export all; # Default is export none
# kernel table 5; # Kernel table to synchronize with (default: main)
}
# This pseudo-protocol watches all interface up/down events.
protocol device {
scan time 10; # Scan interfaces every 10 seconds
}
# your default gateway IP below here (unique to each LB server)
protocol bgp {
export filter packetdns;
local as 65000;
neighbor (PEER_GATEWAY_PRIVATE_IP) as 65530;
#password "md5password"; 
}
