# Written for RouterOS 7.18

# Add static DNS cache entries
/ip/dns/static
:if ([find where name="router.lan"]="") do={
	add address=192.168.11.1 name=router.lan type=A
}
:if ([find where name="boilerplate.hu"]="") do={
	add address=192.168.11.11 name=boilerplate.hu type=A
}
:if ([find where name="gitlab.boilerplate.hu"]="") do={
	add cname=boilerplate.hu name=gitlab.boilerplate.hu type=CNAME
}
:if ([find where name="www.boilerplate.hu"]="") do={
	add cname=boilerplate.hu name=www.boilerplate.hu type=CNAME
}
