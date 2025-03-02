# 3. Megvalósítás

Ez a dokumentáció részletesebb leírást ad az Ubuntu szerver telepítéséről, a Docker konténerek beállításáról és az egyéb konfigurációs lépésekről.

## 3.1 Linux Szerver Konfigurálás

### **Ubuntu 24.04.2**

A telepítés során az alapértelmezett beállításokat használjuk, kivéve amikor megjelenik az **OpenSSH** és **Docker** opció. Ezeket engedélyezzük, majd folytatjuk a telepítést.

---

Miután a telepítés elkészült, frissítsük az **apt** csomagkezelőt:

```bash
sudo apt update
sudo apt upgrade -y
```

---

### Jogosultságok Beállítása

Annak érdekében, hogy ne kelljen minden `docker` parancs előtt `sudo`-t írni, hozzáadjuk a felhasználót a `docker` csoporthoz:

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```

Ajánlott továbbá a felhasználót a `sudo` csoporthoz is hozzáadni:

```bash
sudo usermod -aG sudo $USER
```

Jelentkezzünk be újra a felhasználóba, hogy a változások érvényesüljenek.

```bash
su - $USER
```

---

### Alapvető Eszközök Telepítése

Frissítés után telepítsük a **git** verziókezelőt és az **ansible** automatizálási eszközt:

```bash
sudo apt install git software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

---

### Projekt Klónozása

Klónozzuk le a publikus GitHub repót, amely tartalmazza a szükséges **scripteket**, **konfigurációs** és **Docker** fájlokat, valamint ezt a dokumentációt is:

```bash
git clone https://github.com/OE-NIK-projects/DevEnv-WebService .
```

Lépjünk be a `DevEnv-WebService/config` mappába:

```bash
cd DevEnv-WebService/config
```

## Automatikus Konfiguráció

A lépések a **[Makefile dokumentáció](./makefile.md)**-ban vannak részletezve.

Futtatás előtt ezeknek a feltételeknek teljesülniük kell:

1. A szerveren telepítve van a `make` és a `docker compose`.
2. A felhasználó benne van a `docker` és a `sudo` csoportban.
3. A felhasználó a `docker` mappában van. (Ott ahol a `Makefile` található)

Futtatás:

```bash
sudo make all
```

Ha az alaptól eltérő domain név az elvárás (például `csillamponik.hu`), adjuk ki a következő parancsot:

```bash
sudo make all DOMAIN_NAME=csillamponik.hu
```

Ez a parancs végrehajtja az összes szükséges lépést a GitLab telepítéséhez és beállításához a megadott domain névvel a [`makefile`](../makefile) segítségével.

Miután bebootolt a GitLab, ezen a linken lehet majd elérni: `https://gitlab.csillamponik.hu`

Az alap root jelszót ezzel a paranccsal kérjük le:

```bash
sudo make get-gitlab-password
```

Vagy a következővel:

```bash
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

A belépéshez használjuk a `root` felhasználónevet és az alap root jelszót.

Belépés után **ERŐSEN AJÁNLOTT** megváltoztatni a jelszót!

---

## Manuális Konfiguráció

### Docker Image-ek Letöltése

Navigáljunk a `docker` mappába:

```bash
cd docker
```

Hozzuk létre a GitLab számára a szükséges mappákat:

```bash
mkdir -p gitlab/config gitlab/logs gitlab/data
```

Majd töltsük le a Docker image-eket:

```bash
docker compose pull
```

---

### 53-as Port Felszabadítása DNS Container Számára

Ellenőrizzük, hogy foglalt-e az `53`-as port:

```bash
sudo ss -tulnp | grep :53
```

Ha foglalt, állítsuk le a `systemd-resolved` service-t:

```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo systemctl mask systemd-resolved
```

Ellenőrizzük, hogy sikeresen felszabadult-e:

```bash
sudo ss -tulnp | grep :53
```

Ha nincs visszatérő érték, akkor a port felszabadult.

---

Először meg kell tudnunk, hogy milyen ip címet kapott a szerver.

```bash
ip a
```

Keressük meg azt az interface-t amelynek a neve valamelyikhez hasonlít:

- eth0, eth1
- enpXsY (pl: enp0s3)
- ensX (pl: ens1, ens33)
- brX (pl: br0)
- wlan0, wlan1
- wlpXsY (pl: wlp2s0)

Ha megtaláltuk, akkor keressük meg az `inet` részt és jegyezzük fel az ip címet.

Példa válasz az `ip a` parancsra:

```txt
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:bf:f9:3b brd ff:ff:ff:ff:ff:ff
    altname enp2s1
    inet 192.168.247.132/24 metric 100 brd 192.168.247.255 scope global dynamic ens33
       valid_lft 1663sec preferred_lft 1663sec
    inet6 fe80::20c:29ff:febf:f93b/64 scope link 
       valid_lft forever preferred_lft forever
```

Ebben az esetben a `ens33`-as interfészben az `inet` kulcsszó után a `192.168.247.132` a szerver ip címe.

---

### DNS

Másoljuk le a `dns/dnsmasq-example.conf` fájlt `dns/dnsmasq.conf` néven.

```bash
cp dns/dnsmasq-example.conf dns/dnsmasq.conf
```

Nyissuk meg és módosítsuk a tartalmát.

```bash
nano dns/dnsmasq.conf
```

A fájl tartalma:

```conf
#Logging
log-queries

#Listen on all network interfaces
listen-address=0.0.0.0

#Domain records
address=/example.com/["This machine's ip address"]

#DNS Caching
cache-size=1000

#Upstream Google DNS servers
server=8.8.8.8
server=8.8.4.4

bind-interfaces
```

Cseréljük ki az `example.com` domain nevet arra, amelyen majd el akarjuk érni a webszolgáltatásainkat, mint például a GitLab-ot.

Cseréljük ki a `["This machine's ip address"]`-t a szerver ip címével, amit az előbb kértünk le az `ip a` paranccsal.

Ezzel elértük, hogy amikor egy kliens gépről pingelünk, vagy a böngészőben keresünk rá a dns címre, akkor lefordítja a szerver ip címére.

---

### Környezeti változók módosítása (.env)

Másoljuk le az `.env-example` fájlt `.env` néven, majd szerkesszük:

```bash
cp .env-example .env
nano .env
```

A fájl tartalma:

```conf
#DNS 
DNS_CONTAINER_NAME="dns"
DNS_PORT_UDP=53
DNS_PORT_TCP=53

#Gitlab pre-configuration
GITLAB_CONTAINER_NAME="gitlab"
GITLAB_URL="gitlab.example.com"
GITLAB_SSH_PORT=2424
GITLAB_HOME_DIR="./gitlab"

#Restricting Gitlab memory usage
GITLAB_PUMA_WORKER_PROCESSES=0
GITLAB_PROMETHEUS_MONITORING=false
GITLAB_SIDEKIQ_MAX_CONCURRENCY=10
```

Cseréljük ki a `GITLAB_URL` változó tartalmát, ha a `dnsmasq.conf` fájlba megváltoztattuk a domain nevet.

---

### Konténerek Indítása

Futtassuk a konténereket a `docker compose` segítségével:

```bash
docker compose up -d
```

Ellenőrizzük le az állapotukat:

```bash
docker ps -a
```

---

### Tűzfal Beállítása

Ellenőrizzük le, hogy be van-e kapcsolva a tűzfal:

```bash
sudo ufw status
```

Ha a válaszként `Status: inactive` látható, akkor a tűzfal ki van kapcsolva.

Engedélyezzük az SSH portot először, hogy ne zárjuk ki magunkat:

```bash
sudo ufw allow 22/tcp
```

Majd engedélyezzük a szükséges portokat:

```bash
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw allow 443/tcp
sudo ufw allow 2424/tcp
sudo ufw enable
sudo ufw reload
```

Ellenőrizzük le a beállításokat:

```bash
sudo ufw status
```

Ha a válaszban megtalálhatóak ezek a sorok, akkor sikeresen konfiguráltuk a tűzfalat.

|To        |Action |From      |
|----------|-------|----------|
| 22/tcp   | ALLOW | Anywhere |
| 53/tcp   | ALLOW | Anywhere |
| 53/udp   | ALLOW | Anywhere |
| 443/tcp  | ALLOW | Anywhere |
| 2424/tcp | ALLOW | Anywhere |

---

### GitLab Első Indítása és Jelszó Lekérése

A GitLab telepítése után az első bejelentkezéshez a root jelszót az alábbi paranccsal kaphatjuk meg:

```bash
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

Ezután a GitLab elérhető a böngészőben a `https://gitlab.example.com` címen, amennyiben **NEM** módosítottunk a domain nevet a `dnsmasq.conf` és `.env` fájlokban.

A bejelentkezéshez használjuk a `root` felhasználónevet és a konzolra kiírt ideiglenes jelszót.

---

### GitLab Konfiguráció Webes Felületen

WIP
