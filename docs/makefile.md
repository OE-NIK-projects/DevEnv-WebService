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
