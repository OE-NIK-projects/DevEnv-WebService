# Written for RouterOS 7.18

# Add static DNS cache entries
/ip/dns/static
add address=192.168.11.1 name=boilerplate.hu type=A
add address=192.168.11.11 name=server.boilerplate.hu type=A
