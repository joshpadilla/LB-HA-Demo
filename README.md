# Load Balancing and High Availability Demo with Haproxy and Keepalived
A load balancing and high availability demo on Packet bare metal servers. This terraform module will create a cluster of 2 webservers and 2 load balancers in Active-Passive mode. The webservers are in full layer 2 mode and connect to the haproxy load balancers which are in hybrid networking mode. Haproxy uses a Packet Elastic IP which is announced through BGP with Bird and Keepalived ensures that Haproxy or the Master is healthy. If the Master breaks, then the role switches to the Backup node which happens in a couple of seconds.

![LB-HA](/images/LB-HA.png)

To run this demo, you will need to have Terraform installed. The following commands will deploy the full cluster:

```bash
terraform init
terraform apply
```

If you're interesting in manually deploying this cluster, we have a guide on how to do so here.
