# Written for RouterOS 7.18

# Assign IP address for LAN interface
/ip/address
add address=192.168.11.1/24 interface=ether2 network=192.168.11.0

# Add DHCP pool for LAN
/ip/pool
add name=inside-pool ranges=192.168.11.200-192.168.11.249

# Add a DHCP server for LAN interface
/ip/dhcp-server
add address-pool=inside-pool disabled=no interface=ether2 name=inside-dhcp

# Add DHCP network for LAN
/ip/dhcp-server/network
add address=192.168.11.0/24 comment=inside-network dns-server=192.168.11.1,8.8.8.8 gateway=192.168.11.1 netmask=24

# Add Google's DNS server
/ip/dns
set servers=8.8.8.8

# Setup IP masquerading for LAN
/ip/firewall/nat
add action=masquerade chain=srcnat comment=inside out-interface=ether1
