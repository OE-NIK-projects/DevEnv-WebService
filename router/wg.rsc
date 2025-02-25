/interface wireguard                                                         
    add listen-port=7172 mtu=1420 name=wg private-key="yGQ3FH40WUmzvhHvXI3h/1VaVCRaswXXhOtRQTjymUg="

/interface wireguard peers
    add allowed-address=172.16.16.1/24 interface=wg name=peer1 persistent-keepalive=30s public-key="BqukFThRjwoGSaO8vQMrGuFtxTXUx3diU6QqCSlPcEw="

/ip address
    add address=172.16.1.1/16 interface=wg network=172.16.0.0

/ip firewall nat
    add  action=masquerade chain=srcnat comment=wg out-interface-list=WAN src-address=172.16.16.0/24
