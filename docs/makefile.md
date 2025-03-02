# Makefile dokumentáció

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

## Lépések

### 1. **Környezeti változók konfigurálása**

- A `.env-example` fájl lemásolása `.env` néven.
- A felhasználó szükség esetén manuálisan módosíthatja a fájlt.

### 2. **.env frissítése a megadott domain névvel**

- A `GITLAB_URL` beállítása a `.env` fájlban.

### 3. **Docker környezet beállítása**

- A szükséges mappák létrehozása a GitLab konfigurációhoz, logokhoz és adatokhoz.
- A docker image-ek letöltése.

### 4. **Konténerek indítása**

- A docker konténerek elindítása a `docker compose` segítségével.

### 6. **GitLab root jelszó lekérése**

- A GitLab alap root jelszavának megtekintése a docker konténerből.

A telepítés befejezése után a GitLab elérhető lesz a megadott domainen, és a rendszer használatra kész.
