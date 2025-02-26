# Written for RouterOS 7.18

# Add firewall rules
/ip/firewall/filter
add action=accept chain=input comment="Allow established/related" connection-state=established,related
add action=accept chain=input comment="Allow SSH" dst-port=22 in-interface=ether1 protocol=tcp
add action=accept chain=input comment="Allow WebFig" dst-port=80 in-interface=ether1 protocol=tcp
add action=accept chain=input comment="Allow pinging" in-interface=ether1 protocol=icmp
add action=drop chain=input comment="Block outside" in-interface=ether1
