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

# Lease address for server
/ip/dhcp-server/lease
add address=192.168.11.11 mac-address=00:0C:29:74:F0:BA server=inside-dhcp

# Add DHCP network for LAN
/ip/dhcp-server/network
add address=192.168.11.0/24 comment="LAN" dns-server=192.168.11.1 gateway=192.168.11.1 netmask=24

# Add Google's DNS server and allow clients to use the cache
/ip/dns
set allow-remote-requests=yes servers=8.8.8.8

# Setup IP masquerading for LAN
/ip/firewall/nat
add action=masquerade chain=srcnat comment="LAN" out-interface=ether1
