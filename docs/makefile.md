# Makefile Dokumentáció

Ez a dokumentáció összefoglalja a `Makefile` használatát a GitLab környezet beállításához. A Makefile automatizálja a szükséges lépéseket a konténerek telepítéséhez, indításához és konfigurálásához.

## Használat

Futtatás előtt ezeknek a feltételeknek teljesülniük kell:

1. A szerveren telepítve van a `make` és a `docker compose`.
2. A felhasználó benne van a `docker` és a `sudo` csoportban.
3. A felhasználó a `docker` mappában van. (Ott ahol a `Makefile` található)

Futtatás:

```bash
sudo make all
```

Ha az alaptól eltérő domain nevet és/vagy portot szeretnél használni (például `csillamponik.hu`, ami a `8888`-as porton fut), futtasd a következő parancsot:

```bash
sudo make all DOMAIN_NAME=csillamponik.hu PORT=8888
```

Ez végrehajtja az összes szükséges lépést a GitLab telepítéséhez és beállításához a megadott domain névvel és porttal.

Miután bebootolt a GitLab, ezen a linken lehet majd elérni: `https://gitlab.csillamponik.hu:8888/`

Az alap root jelszót ezzel a paranccsal kérjük le:

```bash
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

A belépéshez használjuk a `root` felhasználónevet és az alap root jelszót.

Belépés után **ERŐSEN AJÁNLOTT** megváltoztatni a jelszót!

---

## Lépések

### 1. **Környezeti változók konfigurálása**

- A `.env-example` fájl lemásolása `.env` néven.
- A felhasználó szükség esetén manuálisan módosíthatja a fájlt.

### 2. **.env frissítése a megadott domain névvel és porttal**

- A `GITLAB_URL` és `GITLAB_PORT` beállítása a `.env` fájlban.

### 3. **DNS konfigurálása**

- A `dnsmasq-example.conf` fájl lemásolása `dnsmasq.conf` néven.
- A szerver IP-címének frissítése a konfigurációs fájlban.

### 4. **Docker környezet beállítása**

- A szükséges mappák létrehozása a GitLab konfigurációhoz, logokhoz és adatokhoz.
- A `systemd-resolved` engedélyezése.
- A docker image-ek letöltése.

### 5. **Systemd-resolved letiltása**

- A `systemd-resolved` szolgáltatás leállítása és tiltása.

### 6. **Konténerek indítása**

- A docker konténerek elindítása a `docker compose` segítségével.

### 7. **Tűzfal konfigurálása**

- Az alábbi portok engedélyezése:
  - 22/tcp (SSH)
  - 53/tcp, 53/udp (DNS)
  - A megadott GitLab port (pl. 8888/tcp)
  - 443/tcp (HTTPS)
  - 2424/tcp (GitLab SSH)
- A tűzfal engedélyezése és frissítése.

### 8. **GitLab root jelszó lekérése**

- A GitLab alap root jelszavának megtekintése a docker konténerből.

A telepítés befejezése után a GitLab elérhető lesz a megadott domainen, és a rendszer használatra kész.
