# Written for RouterOS 7.18

# Create a wireguard interface that listens on port 7172
/interface/wireguard
add listen-port=7172 mtu=1420 name=wg private-key="yGQ3FH40WUmzvhHvXI3h/1VaVCRaswXXhOtRQTjymUg="

# Add remote wireguard peers
/interface/wireguard/peers
add allowed-address=172.16.0.101 interface=wg name=peer1 persistent-keepalive=30s public-key="BqukFThRjwoGSaO8vQMrGuFtxTXUx3diU6QqCSlPcEw="
add allowed-address=172.16.0.102 interface=wg name=peer2 persistent-keepalive=30s public-key="3xmWri54kAjQPFoqPjaGoxUX5wUerEI9wi2Jw57cfgU="

# Assign address to the wireguard interface
/ip/address
add address=172.16.0.1/24 interface=wg network=172.16.0.0

# Setup IP masquerading for wireguard
/ip/firewall/nat
add action=masquerade chain=srcnat comment=WireGuard in-interface=wg out-interface=ether1
