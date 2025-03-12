# Written for RouterOS 7.18

# Remove existing rules
/ip/firewall/filter
remove [find]

# Add WAN rules
add action=accept chain=input comment="Allow established/related" connection-state=established,related
add action=accept chain=input comment="Allow server SSH" dst-port=22 in-interface=ether1 protocol=tcp
add action=accept chain=input comment="Allow server HTTPS" dst-port=443 in-interface=ether1 protocol=tcp
add action=accept chain=input comment="Allow pinging" in-interface=ether1 protocol=icmp
add action=drop chain=input comment="Block outside" in-interface=ether1

# Only allow SSH and WebFig access from the Wireguard tunnel
add action=accept chain=input comment="Allow WebFig from WireGuard" dst-port=80 protocol=tcp src-address=172.16.0.0/24
add action=drop chain=input comment="Block WebFig" dst-port=80 protocol=tcp
add action=accept chain=input comment="Allow SSH from WireGuard" dst-port=2222 protocol=tcp src-address=172.16.0.0/24
add action=drop chain=input comment="Block SSH" dst-port=2222 protocol=tcp

# Forward ports
/ip/firewall/nat
:if ([find where comment="Server SSH"]="") do={
	add action=dst-nat chain=dstnat comment="Server SSH" dst-port=22 in-interface=ether1 protocol=tcp to-addresses=192.168.11.11 to-ports=22
}
:if ([find where comment="Server HTTPS"]="") do={
	add action=dst-nat chain=dstnat comment="Server HTTPS" dst-port=443 in-interface=ether1 protocol=tcp to-addresses=192.168.11.11 to-ports=443
}
