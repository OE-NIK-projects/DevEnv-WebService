# Makefile Dokumentáció

Ez a dokumentáció összefoglalja a `Makefile` használatát a GitLab környezet beállításához. A Makefile automatizálja a szükséges lépéseket a konténerek telepítéséhez, indításához és konfigurálásához.

## Használat

Futtatás előtt ezeknek a feltételeknek teljesülniük kell:

1. A szerveren telepítve van a `make` és a `docker compose`.
2. A felhasználó benne van a `docker` és a `sudo` csoportban.
3. A felhasználó a `docker` mappában van. (Ott ahol a `Makefile` található)

Futtatás:

```bash
make all
```

Ha az alaptól eltérő domain nevet és/vagy portot szeretnél használni (például `csillamponik.hu`, ami a `8888`-as porton fut), futtasd a következő parancsot:

```bash
make all DOMAIN_NAME=csillamponik.hu PORT=8888
```

Ez végrehajtja az összes szükséges lépést a GitLab telepítéséhez és beállításához a megadott domain névvel és porttal.

Miután bebootolt a GitLab, ezen a linken lehet majd elérni: `https://gitlab.csillamponik.hu:8888/`

Az alap root jelszót ezzel a paranccsal lehet elérni.

```bash
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```

A belépéshez használjuk a `root` felhasználónevet és az alap root jelszót.

Belépés után **ERŐSEN AJÁNLOTT** megváltoztatni a jelszót!

---

## Lépések

### 1. Docker image-ek letöltése

```bash
make setup-docker
```

Ez a parancs letölti a szükséges Docker image-eket, és létrehozza a GitLab számára szükséges könyvtárakat.

---

### 2. Környezeti változók konfigurálása

```bash
make configure-env
```

A `.env-example` fájlból létrehozza a `.env` fájlt. Szükség esetén ezt manuálisan kell szerkeszteni a megfelelő beállítások megadásához.

---

### 3. DNS konfiguráció frissítése

```bash
make update-dns
```

Ez a parancs lekéri a gép IP címét és frissíti a `dnsmasq.conf` fájlban szereplő bejegyzést a megfelelő IP-címmel.

---

### 4. `.env` fájl frissítése a domain névvel

```bash
make update-env
```

Ez a parancs automatikusan frissíti a `.env` fájlt, beállítva a `GITLAB_URL` értékét a megadott domain névre (`gitlab.DOMAIN_NAME`).

---

### 5. Konténerek indítása

```bash
make start-containers
```

Elindítja a Docker konténereket a **Docker Compose** segítségével.

---

### 6. Tűzfal beállítása

```bash
make configure-firewall
```

Ez a parancs engedélyezi a szükséges portokat a tűzfalon, majd újratölti a konfigurációt:

- **22/tcp** – SSH hozzáférés
- **53/tcp, 53/udp** – DNS szolgáltatás
- **8000/tcp** – GitLab webes felület
- **443/tcp** – HTTPS
- **2424/tcp** – GitLab SSH kapcsolatok

---

### 7. GitLab root jelszó lekérése

A telepítés után a GitLab root jelszavát az alábbi paranccsal lehet megtekinteni.

```bash
make get-gitlab-password
```
