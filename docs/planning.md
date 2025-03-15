# Boilerplate Kft. Hálózati és Szolgáltatási Infrastruktúra Projekt

## 1. Projekt összefoglaló

A Boilerplate Kft. egy kis költségvetésű, webalkalmazás-fejlesztéssel, szerverüzemeltetéssel és projektmenedzsmenttel foglalkozó vállalkozás. A cél egy költséghatékony, Docker-alapú infrastruktúra kialakítása, amely egyetlen Ubuntu 24.04 LTS szerveren fut, egy MikroTik routerrel biztosítja a hálózati funkcionalitást, valamint támogatja a belső hálózaton működő Windows és Linux klienseket, amelyeken a fejlesztéshez szükséges alkalmazások telepítve vannak.

---

## 2. Követelmények

### 2.1. Általános követelmények

- **Költséghatékonyság**: Minimális hardver- és szoftverlicenc-költségek.
- **Egyszerűség**: Könnyen kezelhető infrastruktúra kis csapattal.
- **Skálázhatóság**: Támogassa a jövőbeli bővítéseket.
- **Biztonság**: Alapvető védelmi mechanizmusok (tűzfal, VPN).

### 2.2. Funkcionális követelmények

- **Hálózati funkcionalitás**:
  - DHCP és DNS a MikroTik routeren keresztül.
  - WireGuard VPN távoli hozzáféréshez.
  - SSH-hozzáférés korlátozott hálózatokból.
- **Szerver funkcionalitás**:
  - Ubuntu 24.04 LTS szerver Docker konténerekkel (GitLab, Nginx, webszolgáltatások).
- **Kliens funkcionalitás**:
  - Windows és Linux kliensek a belső hálózaton (192.168.11.0/24).
  - Fejlesztési környezet: Git, Docker Desktop (Windows/Linux), IDE-k (pl. VS Code), böngészők.
- **Domain kezelés**:
  - Statikus DNS rekordok: `boilerplate.hu`, `gitlab.boilerplate.hu`, `www.boilerplate.hu`.

### 2.3. Hálózat terv

A hálózat egy MikroTik router köré épül, amely az internetkapcsolatot, a belső hálózatot és a VPN-t kezeli.

- **Topológia**:

  ```ansi
  [Internet]
    │
    │
  [MikroTik Router]
    ├── ether1: 10.0.0.128
    ├── ether2: 192.168.11.1
    ├── WireGuard (wg): 172.16.0.1
    │
    │
  [Ubuntu Szerver] — 192.168.11.11
    │
    ├── [Windows Kliens] — 192.168.11.200
    ├── [Linux Kliens]   — 192.168.11.201
  ```

- **Interfészek**:
  - `ether1`: ISP kapcsolat (DHCP kliens).
  - `ether2`: Belső hálózat (192.168.11.0/24).
  - `wg`: VPN alhálózat (172.16.0.0/24).
- **DHCP kiosztás**:
  - Szerver: 192.168.11.11 (fix).
  - Windows kliens: 192.168.11.200 (dinamikus vagy fix).
  - Linux kliens: 192.168.11.201 (dinamikus vagy fix).
- **DNS**:
  - Külső: 8.8.8.8.
  - Statikus rekordok a MikroTik-ban a domainekhez.

### 2.4. Szerver terv

A szerver egy Ubuntu 24.04 LTS alapú rendszer, amely Docker konténerekkel biztosítja a szolgáltatásokat.

- **Hardver**: Minimális követelmény: 4 GB RAM, 2 CPU mag, 50 GB SSD.
- **Szoftver**:
  - OS: Ubuntu 24.04 LTS.
  - Telepített csomagok: OpenSSH, Docker, Docker Compose.
- **Konténerek**:
  - **GitLab**: Verziókezelés és CI/CD.
  - **Nginx**: Reverse proxy a domainekhez.
  - **Webszolgáltatások**: Boilerplate alkalmazások.
- **Hálózat**: Statikus IP (192.168.11.11), 80/443 portokon keresztül kommunikál.

### 2.5. Szerver terv (részletezés)

- **Docker Compose struktúra**:

  ```yaml
  services:
    nginx:
      image: nginx:latest
      ports:
        - "80:80"
        - "443:443"
      volumes:
        - "./nginx.conf:/etc/nginx/nginx.conf"
    gitlab:
      image: gitlab/gitlab-ce:latest
      hostname: gitlab.boilerplate.hu
      volumes:
        - "gitlab/config:/etc/gitlab"
        - "gitlab/logs:/var/log/gitlab"
        - "gitlab/data:/var/gitlab"
    webservice:
      image: boilerplate/webservice:latest
      volumes:
        - "webservice-data:/app/data"
  volumes:
    gitlab-config:
    gitlab-data:
    webservice-data:
  ```

- **Tárolás**: Docker volume-ok a perzisztens adatokhoz.
- **Hozzáférés**: SSH kulcs alapú hitelesítés, VPN-en keresztül.

### 2.6. Kliens terv

A belső hálózaton két kliens található: egy Windows és egy Linux alapú fejlesztői munkaállomás.

- **Windows kliens**:

  - **OS**: Windows 10/11.
  - **IP**: 192.168.11.200 (DHCP vagy fix).
  - **Telepített szoftverek**:
    - Git for Windows.
    - Docker Desktop.
    - Visual Studio Code (vagy más IDE).
    - Böngésző (Chrome/Firefox).
    - WireGuard kliens (VPN-hozzáféréshez).
  - **Felhasználás**: Helyi fejlesztés, GitLab-hozzáférés, Docker konténerek tesztelése.

- **Linux kliens**:

  - **OS**: Ubuntu 22.04/24.04 vagy más disztribúció.
  - **IP**: 192.168.11.201 (DHCP vagy fix).
  - **Telepített szoftverek**:
    - Git.
    - Docker és Docker Compose.
    - Visual Studio Code (vagy más IDE).
    - Böngésző (Chrome/Firefox).
    - WireGuard kliens.
  - **Felhasználás**: Helyi fejlesztés, GitLab-hozzáférés, konténerizált alkalmazások tesztelése.

- **Hálózati integráció**:
  - A kliensek a 192.168.11.0/24 hálózaton belül kommunikálnak a szerverrel.
  - Hozzáférés a `gitlab.boilerplate.hu` és `boilerplate.hu` domainekhez a belső hálózaton keresztül.

## 3. Következtetés

A Boilerplate Kft. infrastruktúrája egy költséghatékony, Docker-alapú megoldást kínál, amely egyetlen szerveren és routeren fut, miközben támogatja a belső hálózaton működő Windows és Linux klienseket. A hálózati, szerver- és kliensoldali tervek biztosítják a fejlesztési igények kielégítését, a tesztelési terv pedig garantálja a rendszer megbízhatóságát és stabilitását.
