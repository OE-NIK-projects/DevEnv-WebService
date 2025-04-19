# Written for RouterOS 7.18

# Assign IP address for LAN interface
/ip/address
:if ([find where address="192.168.11.1/23"]="") do={
	add address=192.168.11.1/23 interface=ether2 network=192.168.10.0
}

# Add DHCP pool for LAN
/ip/pool
:if ([find where name="inside-pool"]="") do={
	add name="inside-pool" ranges=192.168.11.100-192.168.11.199
}

# Add a DHCP server for LAN interface
/ip/dhcp-server
:if ([find where name="inside-dhcp"]="") do={
	add address-pool="inside-pool" interface=ether2 name="inside-dhcp"
}

# Lease address for server
/ip/dhcp-server/lease
:if ([find where address="192.168.11.11"]="") do={
	add address=192.168.11.11 mac-address=00:00:00:00:11:11 server=inside-dhcp
}

# Add DHCP network for LAN
/ip/dhcp-server/network
:if ([find where address="192.168.10.0/23"]="") do={
	add address=192.168.10.0/23 comment="LAN" dns-server=192.168.11.1 gateway=192.168.11.1 netmask=23
}

# Add Google's DNS server and allow clients to use the cache
/ip/dns
set allow-remote-requests=yes servers=8.8.8.8

# Setup IP masquerading for LAN
/ip/firewall/nat
:if ([find where comment="LAN"]="") do={
	add action=masquerade chain=srcnat comment="LAN" in-interface=ether2 out-interface=ether1
}

# Disable unnecessary services
/ip/service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set winbox disabled=yes
set api-ssl disabled=yes
