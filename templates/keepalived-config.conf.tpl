vrrp_script chk_haproxy {
    script "pgrep haproxy"
    interval 2
}

vrrp_instance VI_1 {
    state ${Role}
    interface bond0
    unicast_src_ip ${Main_Server_Private_IPv4}
    unicast_peer {
        ${Peer_Server_Private_IPv4}
    }
    virtual_router_id 101
    priority ${Priority}
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    track_script {
        chk_haproxy
    }
    virtual_ipaddress {
        ${Elastic_IP}
    }
}

vrrp_instance VI_2 {
    state ${Role}
    interface bond0
    unicast_src_ip ${Main_Server_Private_IPv4}
    unicast_peer {
        ${Peer_Server_Private_IPv4}
    }
    virtual_router_id 102
    priority ${Priority}
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    track_script {
        chk_haproxy
    }
    virtual_ipaddress {
        192.168.1.1/24 dev (SECOND_INTERFACE) label gateway:0
    }
}
