# MikroTik Router

RouterOS verzió: 7.18

**[Telepítési útmutató →](setup.md)**


## Alap felhasználó

| Név | Jelszó |
|-|-|
| admin | lalilulelo |


## Interfészek

| Név | Cím | CIDR | |
|-|-|-|-|
| ether1 | 10.0.0.128 | /24 | DHCP |
| ether2 | 192.168.11.1 | /24 | Statikus |
| wg | 172.16.0.1 | /24 | Statikus |


## Szolgáltatások

| Név | Port | Protokoll | Engedélyezett hálózatok |
|-|-|-|-|
| SSH | 22 | TCP | 172.16.0.0/24 |
| DNS | 53 | TCP/UDP | 172.16.0.0/24, 192.168.11.0/24 |
| DHCP | 67 | UDP | 192.168.11.0/24 |
| WebFig (webes kezelőfelület) | 80 | TCP | 172.16.0.0/24 |
| WireGuard VPN | 7172 | UDP | 0.0.0.0/0 |


## DNS

Szerver: 8.8.8.8

### Statikus

| Név | Típus | Cél |
|-|-|-|
| boilerplate.hu | A | 192.168.11.11 |
| gitlab.boilerplate.hu | CNAME | boilerplate.hu |
| www.boilerplate.hu | CNAME | boilerplate.hu |


## DHCP

| Interfész | Hálózat | Tartomány | Átjáró | DNS szerver |
|-|-|-|-|-|
| ether2 | 192.168.11.0/24 | 192.168.11.200-192.168.11.249 | 192.168.11.1 | 192.168.11.1 |

### Foglalások

| Cím | MAC | Megjegyzés |
|-|-|-|
| 192.168.11.11 | 00:0C:29:74:F0:BA | Ubuntu szerver |


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
