/interface ethernet
    set [ find default-name=ether1 ] disable-running-check=no
    set [ find default-name=ether2 ] disable-running-check=no

/interface list
    add name=LAN
    add name=WAN

/ip pool
    add name=inside-pool ranges=192.168.11.200-192.168.11.249

/ip dhcp-server
    add address-pool=inside-pool interface=ether2 name=inside-dhcp

/interface list member
    add interface=ether1 list=WAN
    add interface=ether2 list=LAN

/ip address
    add address=192.168.11.1/24 interface=ether2 network=192.168.11.0

/ip dhcp-client
    add interface=ether1

/ip dhcp-server network
    add address=192.168.11.0/24 comment=inside-network dns-server=192.168.11.1,8.8.8.8 gateway=192.168.11.1 netmask=24

/ip dns
    set servers=8.8.8.8

/ip firewall nat
    add action=masquerade chain=srcnat comment=inside out-interface-list=WAN

/system note
    set show-at-login=no
