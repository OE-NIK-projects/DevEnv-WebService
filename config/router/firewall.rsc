# Written for RouterOS 7.18

# Remove existing rules
/ip/firewall/filter
remove [find]

# Add WAN rules
add action=accept chain=input comment="Allow established/related" connection-state=established,related
add action=accept chain=input comment="Allow pinging" in-interface=ether1 protocol=icmp
add action=accept chain=input comment="Allow server HTTPS" dst-port=443 in-interface=ether1 protocol=tcp
add action=accept chain=input comment="Allow WireGuard" dst-port=7172 in-interface=ether1 protocol=udp
add action=drop chain=input comment="Block outside" in-interface=ether1

# Only allow SSH and WebFig access from the Wireguard tunnel and host
add action=accept chain=input comment="Allow WebFig from WireGuard" dst-port=80 protocol=tcp src-address=172.16.0.0/24
add action=accept chain=input comment="Allow WebFig from host" dst-port=80 protocol=tcp src-address=192.168.10.1
add action=drop chain=input comment="Block WebFig" dst-port=80 protocol=tcp
add action=accept chain=input comment="Allow SSH from WireGuard" dst-port=22 protocol=tcp src-address=172.16.0.0/24
add action=accept chain=input comment="Allow SSH from host" dst-port=22 protocol=tcp src-address=192.168.10.1
add action=drop chain=input comment="Block SSH" dst-port=22 protocol=tcp

# Forward ports
/ip/firewall/nat
:if ([find where comment="Server HTTPS"]="") do={
	add action=dst-nat chain=dstnat comment="Server HTTPS" dst-port=443 in-interface=ether1 protocol=tcp to-addresses=192.168.11.11 to-ports=443
}
