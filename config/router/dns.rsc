# Written for RouterOS 7.18

# Add static DNS cache entries
/ip/dns/static
:if ([find where name="router.lan"]="") do={
	add address=192.168.11.1 name=router.lan type=A
}
:if ([find where name="boilerplate.lan"]="") do={
	add address=192.168.11.11 name=boilerplate.lan type=A
}
:if ([find where name="git.boilerplate.lan"]="") do={
	add cname=boilerplate.lan name=git.boilerplate.lan type=CNAME
}
:if ([find where name="web.boilerplate.lan"]="") do={
	add cname=boilerplate.lan name=web.boilerplate.lan type=CNAME
}
:if ([find where name="webmin.boilerplate.lan"]="") do={
	add cname=boilerplate.lan name=webmin.boilerplate.lan type=CNAME
}
