# 2025-02-25 00:59:25 by RouterOS 7.17.2
# software id = TLZX-09CM
#
/interface ethernet
set [ find default-name=ether1 ] advertise="" arp=enabled arp-timeout=auto auto-negotiation=yes cable-settings=default disable-running-check=no disabled=no loop-protect=default loop-protect-disable-time=5m \
    loop-protect-send-interval=5s mac-address=00:0C:29:6B:40:9E mtu=1500 name=ether1 orig-mac-address=00:0C:29:6B:40:9E
set [ find default-name=ether2 ] advertise="" arp=enabled arp-timeout=auto auto-negotiation=yes cable-settings=default disable-running-check=no disabled=no loop-protect=default loop-protect-disable-time=5m \
    loop-protect-send-interval=5s mac-address=00:0C:29:6B:40:A8 mtu=1500 name=ether2 orig-mac-address=00:0C:29:6B:40:A8
/interface wireguard
add disabled=no listen-port=7172 mtu=1420 name=wg private-key="yGQ3FH40WUmzvhHvXI3h/1VaVCRaswXXhOtRQTjymUg="
/queue interface
set wg queue=no-queue
/interface list
set [ find name=all ] comment="contains all interfaces" exclude="" include="" name=all
set [ find name=none ] comment="contains no interfaces" exclude="" include="" name=none
set [ find name=dynamic ] comment="contains dynamic interfaces" exclude="" include="" name=dynamic
set [ find name=static ] comment="contains static interfaces" exclude="" include="" name=static
add exclude="" include="" name=LAN
add exclude="" include="" name=WAN
/interface lte apn
set [ find default=yes ] add-default-route=yes apn=internet authentication=none default-route-distance=2 ip-type=auto name=default use-network-apn=yes use-peer-dns=yes
/interface macsec profile
set [ find default-name=default ] name=default server-priority=10
/ip dhcp-client option
set clientid_duid code=61 name=clientid_duid value="0xff\$(CLIENT_DUID)"
set clientid code=61 name=clientid value="0x01\$(CLIENT_MAC)"
set hostname code=12 name=hostname value="\$(HOSTNAME)"
/ip hotspot profile
set [ find default=yes ] dns-name="" hotspot-address=0.0.0.0 html-directory=hotspot html-directory-override="" http-cookie-lifetime=3d http-proxy=0.0.0.0:0 install-hotspot-queue=no login-by=cookie,http-chap name=\
    default smtp-server=0.0.0.0 split-user-domain=no use-radius=no
/ip hotspot user profile
set [ find default=yes ] add-mac-cookie=yes address-list="" idle-timeout=none !insert-queue-before keepalive-timeout=2m mac-cookie-timeout=3d name=default !parent-queue !queue-type shared-users=1 \
    status-autorefresh=1m transparent-proxy=no
/ip ipsec mode-config
set [ find default=yes ] name=request-only responder=no use-responder-dns=exclusively
/ip ipsec policy group
set [ find default=yes ] name=default
/ip ipsec profile
set [ find default=yes ] dh-group=modp2048,modp1024 dpd-interval=8s dpd-maximum-failures=4 enc-algorithm=aes-128,3des hash-algorithm=sha1 lifetime=1d name=default nat-traversal=yes proposal-check=obey
/ip ipsec proposal
set [ find default=yes ] auth-algorithms=sha1 disabled=no enc-algorithms=aes-256-cbc,aes-192-cbc,aes-128-cbc lifetime=30m name=default pfs-group=modp1024
/ip pool
add name=inside-pool ranges=192.168.11.200-192.168.11.249
/ip dhcp-server
add address-lists="" address-pool=inside-pool disabled=no interface=ether2 lease-script="" lease-time=30m name=inside-dhcp use-radius=no
/ip smb users
set [ find default=yes ] disabled=no name=guest password="" read-only=yes
/ppp profile
set *0 address-list="" !bridge !bridge-horizon bridge-learning=default !bridge-path-cost !bridge-port-priority !bridge-port-trusted !bridge-port-vid change-tcp-mss=yes !dns-server !idle-timeout !incoming-filter \
    !insert-queue-before !interface-list !local-address name=default on-down="" on-up="" only-one=default !outgoing-filter !parent-queue !queue-type !rate-limit !remote-address !session-timeout use-compression=\
    default use-encryption=default use-ipv6=yes use-mpls=default use-upnp=default !wins-server
set *FFFFFFFE address-list="" !bridge !bridge-horizon bridge-learning=default !bridge-path-cost !bridge-port-priority !bridge-port-trusted !bridge-port-vid change-tcp-mss=yes !dns-server !idle-timeout \
    !incoming-filter !insert-queue-before !interface-list !local-address name=default-encryption on-down="" on-up="" only-one=default !outgoing-filter !parent-queue !queue-type !rate-limit !remote-address \
    !session-timeout use-compression=default use-encryption=yes use-ipv6=yes use-mpls=default use-upnp=default !wins-server
/queue type
set 0 kind=pfifo name=default pfifo-limit=50
set 1 kind=pfifo name=ethernet-default pfifo-limit=50
set 2 kind=sfq name=wireless-default sfq-allot=1514 sfq-perturb=5
set 3 kind=red name=synchronous-default red-avg-packet=1000 red-burst=20 red-limit=60 red-max-threshold=50 red-min-threshold=10
set 4 kind=sfq name=hotspot-default sfq-allot=1514 sfq-perturb=5
set 5 kind=pcq name=pcq-upload-default pcq-burst-rate=0 pcq-burst-threshold=0 pcq-burst-time=10s pcq-classifier=src-address pcq-dst-address-mask=32 pcq-dst-address6-mask=128 pcq-limit=50KiB pcq-rate=0 \
    pcq-src-address-mask=32 pcq-src-address6-mask=128 pcq-total-limit=2000KiB
set 6 kind=pcq name=pcq-download-default pcq-burst-rate=0 pcq-burst-threshold=0 pcq-burst-time=10s pcq-classifier=dst-address pcq-dst-address-mask=32 pcq-dst-address6-mask=128 pcq-limit=50KiB pcq-rate=0 \
    pcq-src-address-mask=32 pcq-src-address6-mask=128 pcq-total-limit=2000KiB
set 7 kind=none name=only-hardware-queue
set 8 kind=mq-pfifo mq-pfifo-limit=50 name=multi-queue-ethernet-default
set 9 kind=pfifo name=default-small pfifo-limit=10
/queue interface
set ether1 queue=only-hardware-queue
set ether2 queue=only-hardware-queue
/routing bgp template
set default as=65530 name=default
/snmp community
set [ find default=yes ] addresses=::/0 authentication-password="" authentication-protocol=MD5 disabled=no encryption-password="" encryption-protocol=DES name=public read-access=yes security=none write-access=no
/system logging action
set 0 memory-lines=1000 memory-stop-on-full=no name=memory target=memory
set 1 disk-file-count=2 disk-file-name=log disk-lines-per-file=1000 disk-stop-on-full=no name=disk target=disk
set 2 name=echo remember=yes target=echo
set 3 bsd-syslog=no name=remote remote=0.0.0.0 remote-port=514 src-address=0.0.0.0 syslog-facility=daemon syslog-severity=auto syslog-time-format=bsd-syslog target=remote
/user group
set read name=read policy=local,telnet,ssh,reboot,read,test,winbox,password,web,sniff,sensitive,api,romon,rest-api,!ftp,!write,!policy skin=default
set write name=write policy=local,telnet,ssh,reboot,read,write,test,winbox,password,web,sniff,sensitive,api,romon,rest-api,!ftp,!policy skin=default
set full name=full policy=local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,password,web,sniff,sensitive,api,romon,rest-api skin=default
/certificate settings
set crl-download=no crl-store=ram crl-use=no
/console settings
set sanitize-names=no
/disk settings
set auto-media-interface=none auto-media-sharing=no auto-smb-sharing=no auto-smb-user=guest default-mount-point-template="[slot]"
/ip smb
set comment=MikrotikSMB domain=MSHOME enabled=auto interfaces=all
/interface bridge port-controller
# disabled
set bridge=none cascade-ports="" switch=none
/interface bridge port-extender
# disabled
set control-ports="" excluded-ports="" switch=none
/interface bridge settings
set allow-fast-path=yes use-ip-firewall=no use-ip-firewall-for-pppoe=no use-ip-firewall-for-vlan=no
/ip firewall connection tracking
set enabled=auto generic-timeout=10m icmp-timeout=10s loose-tcp-tracking=yes tcp-close-timeout=10s tcp-close-wait-timeout=10s tcp-established-timeout=1d tcp-fin-wait-timeout=10s tcp-last-ack-timeout=10s \
    tcp-max-retrans-timeout=5m tcp-syn-received-timeout=5s tcp-syn-sent-timeout=5s tcp-time-wait-timeout=10s tcp-unacked-timeout=5m udp-stream-timeout=3m udp-timeout=30s
/ip neighbor discovery-settings
set discover-interface-list=static discover-interval=30s lldp-mac-phy-config=no lldp-max-frame-size=no lldp-med-net-policy-vlan=disabled lldp-vlan-info=no mode=tx-and-rx protocol=cdp,lldp,mndp
/ip settings
set accept-redirects=no accept-source-route=no allow-fast-path=yes arp-timeout=30s icmp-errors-use-inbound-interface-address=no icmp-rate-limit=10 icmp-rate-mask=0x1818 ip-forward=yes ipv4-multipath-hash-policy=\
    l3 max-neighbor-entries=16384 rp-filter=no secure-redirects=yes send-redirects=yes tcp-syncookies=no tcp-timestamps=random-offset
/ipv6 settings
set accept-redirects=yes-if-forwarding-disabled accept-router-advertisements=yes-if-forwarding-disabled disable-ipv6=no forward=yes max-neighbor-entries=8192 min-neighbor-entries=2048 multipath-hash-policy=l3 \
    soft-max-neighbor-entries=4096 stale-neighbor-detect-interval=30 stale-neighbor-timeout=60
/interface detect-internet
set detect-interface-list=none internet-interface-list=none lan-interface-list=none wan-interface-list=none
/interface l2tp-server server
set accept-proto-version=all accept-pseudowire-type=all allow-fast-path=no authentication=pap,chap,mschap1,mschap2 caller-id-type=ip-address default-profile=default-encryption enabled=no ipsec-secret="" \
    keepalive-timeout=30 l2tpv3-circuit-id="" l2tpv3-cookie-length=0 l2tpv3-digest-hash=md5 !l2tpv3-ether-interface-list max-mru=1450 max-mtu=1450 max-sessions=unlimited mrru=disabled one-session-per-host=no \
    use-ipsec=no
/interface list member
add disabled=no interface=ether1 list=WAN
add disabled=no interface=ether2 list=LAN
/interface lte settings
set esim-channel=auto firmware-path=firmware mode=auto
/interface pptp-server server
# PPTP connections are considered unsafe, it is suggested to use a more modern VPN protocol instead
set authentication=mschap1,mschap2 default-profile=default-encryption enabled=no keepalive-timeout=30 max-mru=1450 max-mtu=1450 mrru=disabled
/interface sstp-server server
set authentication=pap,chap,mschap1,mschap2 certificate=none ciphers=aes256-sha,aes256-gcm-sha384 default-profile=default enabled=no keepalive-timeout=60 max-mru=1500 max-mtu=1500 mrru=disabled pfs=no port=443 \
    tls-version=any verify-client-certificate=no
/interface wifi cap
set enabled=no
/interface wifi capsman
set enabled=no
/interface wireguard peers
add allowed-address=172.16.16.1/24 client-address=172.16.16.1/16 client-dns=172.16.1.1 client-endpoint=192.168.1.254 client-keepalive=30s disabled=no endpoint-address="" endpoint-port=0 interface=wg name=peer1 \
    persistent-keepalive=30s preshared-key="" private-key="YIUdi2PYyH26RWuRZEx07+KVtdWbjpMfqSdkJJ4I410=" public-key="BqukFThRjwoGSaO8vQMrGuFtxTXUx3diU6QqCSlPcEw="
/ip address
add address=192.168.11.1/24 disabled=no interface=ether2 network=192.168.11.0
add address=172.16.1.1/16 disabled=no interface=wg network=172.16.0.0
/ip cloud
# Cloud services not supported on x86
set ddns-enabled=auto ddns-update-interval=none update-time=yes
/ip cloud advanced
# Cloud services not supported on x86
set use-local-address=no
/ip dhcp-client
add add-default-route=yes default-route-distance=1 dhcp-options=hostname,clientid disabled=no interface=ether1 use-peer-dns=yes use-peer-ntp=yes
/ip dhcp-server config
set accounting=yes interim-update=0s radius-password=empty store-leases-disk=5m
/ip dhcp-server network
add address=192.168.11.0/24 caps-manager="" comment=inside-dhcp-net dhcp-option="" dns-server=192.168.11.1,8.8.8.8 gateway=192.168.11.1 netmask=24 !next-server ntp-server="" wins-server=""
/ip dns
set address-list-extra-time=0s allow-remote-requests=no cache-max-ttl=1w cache-size=2048KiB doh-max-concurrent-queries=50 doh-max-server-connections=5 doh-timeout=5s max-concurrent-queries=100 \
    max-concurrent-tcp-sessions=20 max-udp-packet-size=4096 mdns-repeat-ifaces="" query-server-timeout=2s query-total-timeout=10s servers=8.8.8.8 use-doh-server="" verify-doh-cert=no vrf=main
/ip firewall nat
add action=masquerade chain=srcnat comment=inside !connection-bytes !connection-limit !connection-mark !connection-rate !connection-type !content disabled=no !dscp !dst-address !dst-address-list !dst-address-type \
    !dst-limit !fragment !in-bridge-port !in-bridge-port-list !in-interface !in-interface-list !ingress-priority !ipsec-policy !ipv4-options !layer7-protocol !limit log=no log-prefix="" !nth !out-bridge-port \
    !out-bridge-port-list !out-interface out-interface-list=WAN !packet-mark !packet-size !per-connection-classifier !priority !protocol !psd !random !routing-mark !src-address !src-address-list !src-address-type \
    !src-mac-address !time !to-addresses !to-ports !ttl
add action=masquerade chain=srcnat comment=wg !connection-bytes !connection-limit !connection-mark !connection-rate !connection-type !content disabled=no !dscp !dst-address !dst-address-list !dst-address-type \
    !dst-limit !fragment !in-bridge-port !in-bridge-port-list !in-interface !in-interface-list !ingress-priority !ipsec-policy !ipv4-options !layer7-protocol !limit log=no log-prefix="" !nth !out-bridge-port \
    !out-bridge-port-list !out-interface out-interface-list=WAN !packet-mark !packet-size !per-connection-classifier !priority !protocol !psd !random !routing-mark src-address=172.16.16.0/24 !src-address-list \
    !src-address-type !src-mac-address !time !to-addresses !to-ports !ttl
/ip firewall service-port
set ftp disabled=no ports=21
set tftp disabled=no ports=69
set irc disabled=yes ports=6667
set h323 disabled=no
set sip disabled=no ports=5060,5061 sip-direct-media=yes sip-timeout=1h
set pptp disabled=no
set rtsp disabled=yes ports=554
set udplite disabled=no
set dccp disabled=no
set sctp disabled=no
/ip hotspot service-port
set ftp disabled=no ports=21
/ip hotspot user
set [ find default=yes ] comment="counters and limits for trial users" disabled=no name=default-trial
/ip ipsec policy
set 0 disabled=no dst-address=::/0 group=default proposal=default protocol=all src-address=::/0 template=yes
/ip ipsec settings
set accounting=yes interim-update=0s xauth-use-radius=no
/ip media settings
set thumbnails=""
/ip nat-pmp
set enabled=no
/ip proxy
set always-from-cache=no anonymous=no cache-administrator=webmaster cache-hit-dscp=4 cache-on-disk=no cache-path=web-proxy enabled=no max-cache-object-size=2048KiB max-cache-size=unlimited max-client-connections=\
    600 max-fresh-time=3d max-server-connections=600 parent-proxy=:: parent-proxy-port=0 port=8080 serialize-connections=no src-address=::
/ip service
set telnet address="" disabled=no max-sessions=20 port=23 vrf=main
set ftp address="" disabled=no max-sessions=20 port=21 vrf=main
set www address="" disabled=no max-sessions=20 port=80 vrf=main
set ssh address="" disabled=no max-sessions=20 port=22 vrf=main
set www-ssl address="" certificate=none disabled=yes max-sessions=20 port=443 tls-version=any vrf=main
set api address="" disabled=no max-sessions=20 port=8728 vrf=main
set winbox address="" disabled=no max-sessions=20 port=8291 vrf=main
set api-ssl address="" certificate=none disabled=no max-sessions=20 port=8729 tls-version=any vrf=main
/ip smb shares
set [ find default=yes ] directory=pub disabled=yes invalid-users="" name=pub read-only=no require-encryption=no valid-users=""
/ip socks
set auth-method=none connection-idle-timeout=2m enabled=no max-connections=200 port=1080 version=4 vrf=main
/ip ssh
set always-allow-password-login=no ciphers=auto forwarding-enabled=no host-key-size=2048 host-key-type=rsa strong-crypto=no
/ip tftp settings
set max-block-size=4096
/ip traffic-flow
set active-flow-timeout=30m cache-entries=128k enabled=no inactive-flow-timeout=15s interfaces=all packet-sampling=no sampling-interval=0 sampling-space=0
/ip traffic-flow ipfix
set bytes=yes dst-address=yes dst-address-mask=yes dst-mac-address=yes dst-port=yes first-forwarded=yes gateway=yes icmp-code=yes icmp-type=yes igmp-type=yes in-interface=yes ip-header-length=yes ip-total-length=\
    yes ipv6-flow-label=yes is-multicast=yes last-forwarded=yes nat-dst-address=yes nat-dst-port=yes nat-events=no nat-src-address=yes nat-src-port=yes out-interface=yes packets=yes protocol=yes src-address=yes \
    src-address-mask=yes src-mac-address=yes src-port=yes sys-init-time=yes tcp-ack-num=yes tcp-flags=yes tcp-seq-num=yes tcp-window-size=yes tos=yes ttl=yes udp-length=yes
/ip upnp
set allow-disable-external-interface=no enabled=no show-dummy-rule=yes
/ipv6 nd
set [ find default=yes ] advertise-dns=yes advertise-mac-address=yes disabled=no hop-limit=unspecified interface=all managed-address-configuration=no mtu=unspecified other-configuration=no ra-delay=3s \
    ra-interval=3m20s-10m ra-lifetime=30m ra-preference=medium reachable-time=unspecified retransmit-interval=unspecified
/ipv6 nd prefix default
set autonomous=yes preferred-lifetime=1w valid-lifetime=4w2d
/mpls settings
set allow-fast-path=yes dynamic-label-range=16-1048575 propagate-ttl=yes
/ppp aaa
set accounting=yes enable-ipv6-accounting=no interim-update=0s use-circuit-id-in-nas-port-id=no use-radius=no
/radius incoming
set accept=no port=3799 vrf=main
/routing igmp-proxy
set query-interval=2m5s query-response-interval=10s quick-leave=no
/routing settings
set single-process=no
/snmp
set contact="" enabled=no engine-id-suffix="" location="" src-address=:: trap-community=public trap-generators=temp-exception trap-target="" trap-version=1 vrf=main
/system clock
set time-zone-autodetect=yes time-zone-name=manual
/system clock manual
set dst-delta=+00:00 dst-end="1970-01-01 00:00:00" dst-start="1970-01-01 00:00:00" time-zone=+00:00
/system console
set [ find vcno=1 ] channel=0 disabled=no term=linux
set [ find vcno=2 ] channel=0 disabled=no term=linux
set [ find vcno=3 ] channel=0 disabled=no term=linux
set [ find vcno=4 ] channel=0 disabled=no term=linux
set [ find vcno=5 ] channel=0 disabled=no term=linux
set [ find vcno=6 ] channel=0 disabled=no term=linux
set [ find vcno=7 ] channel=0 disabled=no term=linux
set [ find vcno=8 ] channel=0 disabled=no term=linux
/system console screen
set blank-interval=10min line-count=25
/system hardware
set allow-x86-64=no multi-cpu=yes
/system health
set state-after-reboot=enabled
/system identity
set name=MikroTik
/system leds settings
set all-leds-off=never
/system logging
set 0 action=memory disabled=no prefix="" regex="" topics=info
set 1 action=memory disabled=no prefix="" regex="" topics=error
set 2 action=memory disabled=no prefix="" regex="" topics=warning
set 3 action=echo disabled=no prefix="" regex="" topics=critical
/system note
set note="" show-at-cli-login=no show-at-login=no
/system ntp client
set enabled=no mode=unicast servers="" vrf=main
/system ntp server
set auth-key=none broadcast=no broadcast-addresses="" enabled=no local-clock-stratum=5 manycast=no multicast=no use-local-clock=no vrf=main
/system package local-update mirror
set check-interval=1d enabled=no primary-server=0.0.0.0 secondary-server=0.0.0.0 user=""
/system resource irq
set 0 cpu=auto
set 1 cpu=auto
set 2 cpu=auto
set 3 cpu=auto
set 4 cpu=auto
set 5 cpu=auto
set 6 cpu=auto
/system resource irq rps
set ether1 disabled=no
set ether2 disabled=no
/system resource usb settings
set authorization=no
/system watchdog
set auto-send-supout=no automatic-supout=yes ping-start-after-boot=5m ping-timeout=1m watch-address=none watchdog-timer=yes
/tool bandwidth-server
set allocate-udp-ports-from=2000 authenticate=yes enabled=yes max-sessions=100
/tool e-mail
set from=<> password="" port=25 server=0.0.0.0 tls=no user="" vrf=main
/tool graphing
set page-refresh=300 store-every=5min
/tool mac-server
set allowed-interface-list=all
/tool mac-server mac-winbox
set allowed-interface-list=all
/tool mac-server ping
set enabled=yes
/tool romon
set enabled=no id=00:00:00:00:00:00 secrets=""
/tool romon port
set [ find default=yes ] cost=100 disabled=no forbid=no interface=all secrets=""
/tool sms
set allowed-number="" channel=0 polling=no port=none receive-enabled=no secret="" sim-pin="" sms-storage=sim
/tool sniffer
set file-limit=1000KiB file-name="" filter-cpu="" filter-direction=any filter-dst-ip-address="" filter-dst-ipv6-address="" filter-dst-mac-address="" filter-dst-port="" filter-interface="" filter-ip-address="" \
    filter-ip-protocol="" filter-ipv6-address="" filter-mac-address="" filter-mac-protocol="" filter-operator-between-entries=or filter-port="" filter-size="" filter-src-ip-address="" filter-src-ipv6-address="" \
    filter-src-mac-address="" filter-src-port="" filter-stream=no filter-vlan="" memory-limit=100KiB memory-scroll=yes only-headers=no quick-rows=20 quick-show-frame=no streaming-enabled=no streaming-server=\
    0.0.0.0:37008
/tool traffic-generator
set latency-distribution-max=100us measure-out-of-order=no stats-samples-to-keep=100 test-id=0
/user aaa
set accounting=yes default-group=read exclude-groups="" interim-update=0s use-radius=no
/user settings
set minimum-categories=0 minimum-password-length=0
