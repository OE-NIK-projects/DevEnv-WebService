# Boilerplate Kft. Hálózati és Szolgáltatási Infrastruktúra Projekt

## 1. Projekt összefoglaló

A Boilerplate Kft. egy kis költségvetésű, webalkalmazás-fejlesztéssel, szerverüzemeltetéssel, projektmenedzsmenttel és felhő alapú megoldásokkal foglalkozó vállalkozás. A cél egy költséghatékony, Docker alapú infrastruktúra kialakítása, amely egyetlen Ubuntu 24.04 LTS szerveren fut, valamint a hálózati funkcionalitásért egy MikroTik router felel.

A projekt figyelembe veszi a cég Docker iránti elkötelezettségét, a GitLab verziókezelő rendszer használatát, valamint a meglévő erőforrások lehető leghatékonyabb kihasználását.

---

## 2. Követelmények

### 2.1. Általános követelmények

- **Költséghatékonyság**: A megoldás minimális hardver- és szoftverlicenc-költségekkel működjön.
- **Egyszerűség**: Az infrastruktúra könnyen kezelhető legyen egy kis csapattal.
- **Skálázhatóság**: A rendszer támogassa a jövőbeli bővítéseket (pl. további szolgáltatások Docker konténerekben).
- **Biztonság**: Alapvető védelmi mechanizmusok (tűzfal, VPN) biztosítsák a hálózati és szerverszintű hozzáférést.

### 2.2. Funkcionális követelmények

- **Hálózati funkcionalitás**:
  - DHCP és DNS szolgáltatás a MikroTik routeren keresztül.
  - WireGuard VPN távoli hozzáféréshez.
  - SSH-hozzáférés a szerverhez és routerhez korlátozott hálózatokból.
- **Szerver funkcionalitás**:
  - Egy Ubuntu 24.04 LTS szerveren futó Docker konténerek biztosítják a szolgáltatásokat.
  - GitLab verziókezelő rendszer Docker konténerben.
  - Nginx webszerver Docker konténerben az URL-ek kiszolgálására (`boilerplate.hu`, `gitlab.boilerplate.hu`).
  - Webszolgáltatások Docker konténerekben.
- **Domain kezelés**:
  - Statikus DNS rekordok a MikroTik routeren: `boilerplate.hu`, `gitlab.boilerplate.hu`, `www.boilerplate.hu`.

### 2.3. Nem funkcionális követelmények

- **Teljesítmény**: A rendszer támogassa egy kis fejlesztőcsapat (5-10 fő) egyidejű munkáját.
- **Üzemidő**: Minimális állásidő (99% rendelkezésre állás) a szolgáltatások számára.
- **Karbantarthatóság**: A konfigurációk dokumentáltak és szkriptekkel automatizálhatók legyenek.

---

## 3. Követelmények részletezése

### 3.1. Specifikáció

#### 3.1.1. Hálózati specifikáció

- **Router**: MikroTik RouterOS 7.18
  - Interfészek:
    - `ether1`: 10.0.0.128/24 (DHCP kliens az ISP felől).
    - `ether2`: 192.168.11.1/24 (belső hálózat átjárója).
    - `wg`: 172.16.0.1/24 (WireGuard VPN hálózat).
  - Szolgáltatások:
    - DHCP szerver: 192.168.11.200-249 tartomány, 192.168.11.11 fixen a szervernek.
    - DNS szerver: 8.8.8.8 továbbítás, statikus rekordok a domainekhez.
    - NAT: Masquerade az `ether2` és `wg` interfészekhez.
    - Tűzfal: 443-as port továbbítás a szerverre (192.168.11.11).
  - Távoli elérés:
    - WireGuard VPN: 7172-es port.
    - SSH: 22-es port, csak 172.16.0.0/24-ből.
    - WebFig: 80-as port, csak 172.16.0.0/24-ből.

#### 3.1.2. Szerver specifikáció

- **Operációs rendszer**: Ubuntu 24.04 LTS
  - Telepített komponensek: OpenSSH, Docker, Docker Compose.
  - Statikus IP: 192.168.11.11.
- **Docker konténerek**:
  - **GitLab**: Verziókezelés és CI/CD.
  - **Nginx**: Webkiszolgáló, reverse proxy a domainekhez.
  - **Webszolgáltatások**: Boilerplate Kft. saját alkalmazásai.
- **Hálózati konfiguráció**: A konténerek a szerver IP-címén (192.168.11.11) érhetők el, az Nginx kezeli a forgalmat.

### 3.2. Használati esetek

#### 3.2.1. UC-01: Fejlesztő távoli hozzáférése a GitLab-hoz

- **Szereplő**: Fejlesztő.
- **Előfeltétel**: WireGuard VPN kliens konfigurálva a fejlesztő eszközén.
- **Folyamat**:
  1. A fejlesztő csatlakozik a VPN-hez (172.16.0.0/24).
  2. Böngészőben megnyitja a `gitlab.boilerplate.hu` címet.
  3. Bejelentkezik, és eléri a projekt repókat.
- **Eredmény**: A fejlesztő hozzáfér a GitLab funkciókhoz.

#### 3.2.2. UC-02: Webszolgáltatás elérése az internetről

- **Szereplő**: Külső felhasználó.
- **Előfeltétel**: Internetkapcsolat.
- **Folyamat**:
  1. A felhasználó böngészőben megnyitja a `boilerplate.hu` címet.
  2. A MikroTik NAT továbbítja a 443-as port forgalmát a szerverre.
  3. Az Nginx kiszolgálja a kérést.
- **Eredmény**: A felhasználó eléri a Boilerplate Kft. webalkalmazását.

#### 3.2.3. UC-03: Szerveradminisztráció SSH-n keresztül

- **Szereplő**: Rendszergazda.
- **Előfeltétel**: VPN kapcsolat.
- **Folyamat**:
  1. A rendszergazda SSH-val csatlakozik a 192.168.11.11 címre.
  2. Docker konténereket kezel (pl. `docker ps`, `docker-compose`).
- **Eredmény**: A szerver konfigurációja módosítható.

---

## 4. Tervezés

### 4.1. Hálózati architektúra

```
[Internet] --- [MikroTik Router] --- [Ubuntu Szerver]
                | 10.0.0.128 (ether1)   | 192.168.11.11
                | 192.168.11.1 (ether2) |
                | 172.16.0.1 (wg)       |
```

- A MikroTik router az internet és a belső hálózat között közvetít.
- A szerver a 192.168.11.0/24 hálózaton belül működik.
- A WireGuard VPN külön alhálózatot (172.16.0.0/24) biztosít a távoli hozzáféréshez.

### 4.2. Szerver architektúra

```
Ubuntu 24.04 LTS
  ├── Docker
  │    ├── GitLab (gitlab.boilerplate.hu)
  │    ├── Nginx (boilerplate.hu, reverse proxy)
  │    └── Webszolgáltatások (alkalmazások)
  └── OpenSSH (távoli adminisztráció)
```

- Az Nginx a bejövő forgalmat a megfelelő konténerhez irányítja.
- A Docker Compose kezeli a konténerek konfigurációját és indítását.

### 4.3. Docker Compose konfiguráció (példa)

```yaml
version: "3"
services:
  nginx:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - gitlab
      - webservice
  gitlab:
    image: gitlab/gitlab-ce:latest
    hostname: gitlab.boilerplate.hu
    volumes:
      - gitlab-config:/etc/gitlab
      - gitlab-logs:/var/log/gitlab
      - gitlab-data:/var/opt/gitlab
  webservice:
    image: boilerplate/webservice:latest
    volumes:
      - webservice-data:/app/data
volumes:
  gitlab-config:
  gitlab-logs:
  gitlab-data:
  webservice-data:
```

### 4.4. Biztonsági tervezés

- **Tűzfal**: A MikroTik csak a szükséges portokat (443, 7172) nyitja meg az internet felől.
- **VPN**: WireGuard titkosított csatornát biztosít a távoli hozzáféréshez.
- **Jogosultságok**: Jelszó nélküli sudo csak az `ubuntu` felhasználónak, SSH kulcs alapú hitelesítéssel.

---

## 5. Következtetés

A Boilerplate Kft. számára kialakított infrastruktúra költséghatékony, Docker alapú megoldást kínál, amely egy szerveren és routeren fut. A rendszer támogatja a cég alapvető működését és rugalmasan bővíthető a jövőben különböző szolgáltatásokkal (docker konténerekkel). A dokumentáció és az automatizált szkriptek biztosítják a karbantarthatóságot és az egyszerű üzemeltetést.
