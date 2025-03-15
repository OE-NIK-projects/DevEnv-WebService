# MikroTik Router

**[Telepítési útmutató →](setup.md)**

---

RouterOS verzió: 7.18

Alap felhasználónév: `admin`\
Alap jelszó: `lalilulelo`


## Interfészek

| Név | Cím | CIDR | |
|-|-|-|-|
| ether1 | 10.0.0.128 | /24 | DHCP |
| ether2 | 192.168.11.1 | /24 | Statikus |
| wg | 172.16.0.1 | /24 | Statikus |


## Távoli elérés

### WireGuard VPN

Elérhető a 7172-es porton keresztül minden hálózatról.

### SSH

Elérhető a 22-es porton keresztül a 172.16.0.0/24-es hálózatból.

### WebFig (webes kezelőfelület)

Elérhető a 80-as porton keresztül a 172.16.0.0/24-es hálózatból.


## DHCP

A `192.168.11.11` le van foglalva a Linux szerver számára

| Interfész | Hálózat | Tartomány | Átjáró | DNS szerver |
|-|-|-|-|-|
| ether2 | 192.168.11.0/24 | 192.168.11.200-192.168.11.249 | 192.168.11.1 | 192.168.11.1 |


## DNS

Szerver: 8.8.8.8

### Statikus

| Név | Típus | Cél |
|-|-|-|
| boilerplate.hu | A | 192.168.11.11 |
| gitlab.boilerplate.hu | CNAME | boilerplate.hu |
| www.boilerplate.hu | CNAME | boilerplate.hu |


## Tűzfal

### NAT

| Név | Művelet | Be interfész | Ki interfész |
|-|-|-|-|
| LAN | masquerade | ether2 | ether1 |
| WireGuard | masquerade | wg | ether1 |

### Továbbított portok

| Forrás port | Cél cím | Cél port |
|-|-|-|
| 443 | 192.168.11.11 | 443 |


## Szkriptek

- [Alap beállítások](../../config/router/basic.rsc)
- [DNS szerver](../../config/router/dns.rsc)
- [WireGuard VPN](../../config/router/wg.rsc)
- [Tűzfal szűrők](../../config/router/firewall.rsc)
