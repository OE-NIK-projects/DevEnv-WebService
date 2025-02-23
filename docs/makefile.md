# Makefile Dokumentáció

Ez a dokumentáció összefoglalja a `Makefile` használatát a GitLab környezet beállításához. A Makefile automatizálja a szükséges lépéseket a konténerek telepítéséhez, indításához és konfigurálásához.

## Használat

A Makefile használatához először győződjünk meg róla, hogy a rendszerünkön telepítve van a `Make` és a `Docker Compose`.

A felhasználó benne van a `docker` és a `sudo` csoportban.

Futtatás:

```bash
make all
```

Ez végrehajtja az összes szükséges lépést a GitLab telepítéséhez és beállításához.

Ha egy adott lépést külön szeretnénk futtatni, használhatjuk az alábbi parancsokat.

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

### 3. Konténerek indítása

```bash
make start-containers
```

Elindítja a Docker konténereket a **Docker Compose** segítségével.

---

### 4. Tűzfal beállítása

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

### 5. GitLab root jelszó lekérése

A telepítés után a GitLab root jelszavát az alábbi paranccsal lehet megtekinteni.

```bash
make get-gitlab-password
```
