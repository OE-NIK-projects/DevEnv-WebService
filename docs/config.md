# 3. Megvalósítás

Ez a dokumentáció részletesebb leírást ad az Ubuntu szerver telepítéséről, a Docker konténerek beállításáról és az egyéb konfigurációs lépésekről.

## 3.1 Linux Szerver Konfigurálás

### **Ubuntu 24.04.2**

A telepítés során az alapértelmezett beállításokat használjuk, kivéve amikor megjelenik az **OpenSSH** és **Docker** opció. Ezeket engedélyezzük, majd folytatjuk a telepítést.

---

### Jelszó nélküli sudo konfiguráció

### 1. A sudoers fájl szerkesztése

A jelszó nélküli sudo beállításához biztonságosan kell módosítanu a sudoers fájlt. Ehhez a `visudo` parancsot ajánlott használni, mivel ez ellenőrzi a szintaxist a mentés előtt.

```bash
sudo visudo
```

### 2. A felhasználó hozzáadása

A sudoers fájl végére illeszük be a következő sort (például, ha a felhasználó neve `ubuntu`):

```bash
ubuntu ALL=(ALL) NOPASSWD:ALL
```

Ez a beállítás lehetővé teszi, hogy az `ubuntu` felhasználó bármely parancsot futtasson sudo jogokkal anélkül, hogy jelszót kérne.

### 3. A fájl mentése és kilépés

- **Nano használata esetén:**
  - Mentés: `Ctrl+O`
  - Kilépés: `Ctrl+X`
- **Vim használata esetén:**  
  Írjuk be a `:wq` parancsot és nyomjuk meg az Entert a mentéshez és kilépéshez.

### 4. A konfiguráció tesztelése

Teszteljük a beállítást egy egyszerű sudo parancs futtatásával:

```bash
sudo apt update
```

Ha minden rendben van, a parancs futtatása során nem kér jelszót.

---

## Automatikus Konfiguráció

A `Deploy-Gitlab.ps1` szkript célja egy GitLab példány automatizált telepítése egy távoli szerverre Docker használatával.

## Áttekintés

A szkript egy távoli szerveren állít fel egy GitLab környezetet az alábbi lépések végrehajtásával:

1. Távoli hozzáférés beállítása (felhasználónév és hoszt megadása).
2. SSH kulcs alapú hitelesítés konfigurálása.
3. Szerver alapvető konfigurálása (csomagfrissítések, Docker csoport létrehozása).
4. GitLab környezet előkészítése (mappák, környezetfájlok, Docker Compose).
5. GitLab elindítása és hozzáférési információk kiírása.

## Fő Végrehajtás

A szkript a következő lépéseket hajtja végre sorrendben:

1. **Távoli Hozzáférés** (`Set-RemoteAccess`): Beállítja a távoli hozzáférést.
2. **SSH Hitelesítés** (`Set-SSHAuthentication`): Beállítja az SSH kulcs alapú hitelesítést.
3. **Szerver Konfiguráció** (`Set-ServerConfiguration`): Elvégzi a szerver alapvető konfigurációját.
4. **GitLab Konfiguráció** (`Setup-Gitlab`): Előkészíti és elindítja a GitLab környezetet.
5. **Hozzáférési Információk** (`Write-AccessInfo`): Kiírja a hozzáférési adatokat.

## Használat

1. **Előfeltételek**:

   - A DevEnv-WebService repó klónozva/letöltve.
   - PowerShell környezet (Windows, Linux vagy macOS).
   - PowerShell ^7.5.0
   - SSH és SCP eszközök telepítve.
   - Docker és Docker Compose telepítve a távoli szerveren.
   - A `docker-compose.yml` fájl létezik a szkript könyvtárában.
   - [Jelszó nélküli sudo parancsok lehetséges futtatása](#jelszó-nélküli-sudo-konfiguráció)

2. **Klónozás**
   Amennyiben telepítve van a `Git` verziókezelő, klónozzuk le annak a segítségével.

   ```cmd
   git clone https://github.com/OE-NIK-projects/DevEnv-WebService
   ```

   Vagy töltsük le manuálisan `.zip` formátumban innen: [DevEnv-WebService](https://github.com/OE-NIK-projects/DevEnv-WebService)

   Csomagoljuk ki és lépjünk bele a `DevEnv-WebService/config/scripts/server` mappába.

   ```poweshell
   cd .\DevEnv-WebService\config\scripts\server
   ```

3. **Futtatás**:
  Futtassuk a `Deploy-Gitlab.ps1` powershell szkriptet.

   ```poweshell
   .\Deploy-Gitlab.ps1
   ```

   - A szkript interaktív: kéri a felhasználótól a távoli hozzáférési adatokat, SSH hitelesítési döntést és az adminisztrátori jelszót.

4. **Kimenet**:
   - A szkript lépésről lépésre kiírja az állapotokat (pl. "SSH key uploaded", "GitLab started").
   - Végül megjeleníti a különböző szolgáltatások hozzáférési adatait.

## Javaslatok

- **Biztonság**: Az alapértelmezett adminisztrátori jelszót (`Password1!`) azonnal változtassa meg a GitLab első bejelentkezéskor.
- **Testreszabás**: A `$Config` objektumban módosíthatja az alapértelmezett értékeket (pl. domain, SSH kulcs méret).
- **Hibakeresés**: Ha probléma adódik, ellenőrizze a konzolon kiírt hibaüzeneteket, és biztosítsa, hogy a távoli szerver elérhető legyen.

## Konfigurációs Objektumok

### 1. `$Config` - Konfigurációs Objektum

Ez a hashtable tárolja a szkript alapvető konfigurációs adatait.

- **RemoteUser**: Távoli felhasználónév (alapértelmezetten `null`, a felhasználó adja meg futás közben).
- **RemoteHost**: Távoli hoszt (IP-cím vagy hosztnév, alapértelmezetten `null`, futás közben adja meg a felhasználó).
- **HomeDir**: A felhasználó otthoni könyvtára (`$env:HOME` vagy `$env:USERPROFILE` alapján).
- **SSHKeySize**: SSH kulcs mérete (alapértelmezetten 4096 bit).
- **DockerDir**: A Docker munkakönyvtár helye a távoli szerveren (`~/docker`).
- **ServerDomain**: A szerver domain neve (`boilerplate.hu`).
- **GitlabRootUsername**: A GitLab adminisztrátori felhasználóneve (`root`).
- **GitlabRootPassword**: A GitLab adminisztrátori jelszava (`Password1!`).
- **ScriptRoot**: A szkript futtatási könyvtára (`$PSScriptRoot`).

### 2. `$Paths` - Útvonalak

Ez a hashtable a konfigurációból származtatott útvonalakat tartalmazza.

- **SSHKeyPath**: Az SSH privát kulcs helye (`~/.ssh/gitlab_id_rsa`).
- **SSHPubKey**: Az SSH publikus kulcs helye (`~/.ssh/gitlab_id_rsa.pub`).
- **GitlabDir**: A GitLab munkakönyvtára a távoli szerveren (`~/docker/gitlab`).
- **DotEnvFile**: A `.env` környezetfájl helye a helyi gépen.
- **DockerComposeFile**: A `docker-compose.yml` fájl helye a helyi gépen.

### 3. `$Domains` - Domain Konfiguráció

Ez a hashtable a szerver domainjeit tartalmazza.

- **WebApp**: A webalkalmazás domainje (`webapp.boilerplate.hu`).
- **Gitlab**: A GitLab domainje (`gitlab.boilerplate.hu`).

## Segédfüggvények

### 1. `Invoke-SSH`

**Leírás**: SSH parancsot futtat a távoli szerveren.  
**Paraméterek**:

- `$Command`: A futtatandó parancs (string).

**Működés**: Az SSH kulcs használatával (`$Paths.SSHKeyPath`) csatlakozik a távoli szerverhez (`$Config.RemoteUser@$Config.RemoteHost`), és végrehajtja a megadott parancsot.

### 2. `Invoke-SCP`

**Leírás**: Fájlokat másol a helyi gépről a távoli szerverre SCP protokoll használatával.  
**Paraméterek**:

- `$Source`: A másolandó fájl helyi elérési útja.
- `$Destination`: A célhely a távoli szerveren.

**Működés**: Az SSH kulcs használatával másolja a fájlt a megadott helyre.

### 3. `Test-CommandSuccess`

**Leírás**: Ellenőrzi egy parancs sikerességét a `$LASTEXITCODE` alapján, és kiírja az eredményt.  
**Paraméterek**:

- `$SuccessMessage`: A siker esetén megjelenő üzenet.
- `$FailureMessage`: A hiba esetén megjelenő üzenet.
- `$Result`: Az opcionális parancskimenet (alapértelmezetten üres).

**Működés**: Ha `$LASTEXITCODE` 0, akkor a parancs sikeres, és kiírja az üzenetet zöld színnel. Ellenkező esetben figyelmeztetést ír ki sárga színnel, és a hibakódot is megjeleníti. Visszatérési értéke `$true` (siker) vagy `$false` (hiba).

## Alapvető Függvények

### 1. `Set-RemoteAccess`

**Leírás**: Beállítja a távoli hozzáférés adatait (felhasználónév és hoszt).

**Működés**:

- Kéri a felhasználótól a távoli felhasználónevet és hosztot (IP vagy hosztnév).
- Ellenőrzi, hogy a megadott értékek nem üresek.
- Pingeli a hosztot (`Test-Connection`) a kapcsolat ellenőrzéséhez.
- Ha a hoszt elérhető, beállítja a `$Config.RemoteUser` és `$Config.RemoteHost` értékeket.
- Hibakezelés: Ha a hoszt nem érhető el, vagy üres értéket adnak meg, hibaüzenetet ír ki, és újrapróbálkozik.

### 2. `New-SSHKey`

**Leírás**: Új SSH kulcsot generál a megadott méretben.  
**Paraméterek**:

- `$KeySize`: A kulcs mérete (alapértelmezetten `$Config.SSHKeySize`, azaz 4096 bit).

**Működés**:

- Az `ssh-keygen` parancs segítségével generál egy RSA kulcsot jelszó nélkül.
- Ellenőrzi a parancs sikerességét a `Test-CommandSuccess` függvény segítségével.
- Ha a kulcs generálása sikertelen, kivételt dob.

### 3. `Send-SSHKey`

**Leírás**: Feltölti az SSH publikus kulcsot a távoli szerverre.

**Működés**:

- Beolvassa a publikus kulcs tartalmát (`$Paths.SSHPubKey`).

- Az `Invoke-SSH` segítségével létrehozza a `~/.ssh` mappát a távoli szerveren, és hozzáfűzi a kulcsot az `authorized_keys` fájlhoz.
- Ellenőrzi a feltöltés sikerességét a `Test-CommandSuccess` függvény segítségével.

### 4. `Test-SSHConnection`

**Leírás**: Teszteli az SSH kapcsolatot a feltöltött kulcs segítségével.

**Működés**:

- Egy egyszerű `echo` parancsot futtat a távoli szerveren az `Invoke-SSH` használatával.
- Ellenőrzi a parancs sikerességét a `Test-CommandSuccess` függvény segítségével, és kiírja az eredményt.

### 5. `Set-SSHAuthentication`

**Leírás**: Beállítja az SSH kulcs alapú hitelesítést.

**Működés**:

- Kérdezi a felhasználótól, hogy beállítsa-e az SSH hitelesítést (alapértelmezetten igen).
- Ha nincs meglévő publikus kulcs, kéri a kulcs méretét, majd a `New-SSHKey` függvény segítségével generál egy új kulcsot.
- Feltölti a kulcsot a `Send-SSHKey` függvény segítségével.
- Teszteli a kapcsolatot a `Test-SSHConnection` függvény segítségével.
- Ha a felhasználó nemet választ, a szkript kilép.

### 6. `Set-ServerConfiguration`

**Leírás**: Alapvető szerverkonfigurációt végez a távoli szerveren.

**Működés**:

- Frissíti a csomagokat (`apt update` és `apt upgrade`).
- Eltávolítja a nem használt csomagokat (`apt autoremove`).
- Létrehozza a `docker` csoportot, és a távoli felhasználót hozzáadja a `docker` és `sudo` csoportokhoz.
- Minden lépés sikerességét ellenőrzi a `Test-CommandSuccess` függvény segítségével.

### 7. `New-GitlabDirectories`

**Leírás**: Létrehozza a GitLab számára szükséges mappákat a távoli szerveren.

**Működés**:

- Az `Invoke-SSH` használatával létrehozza a `config`, `data`, és `logs` mappákat a `$Paths.GitlabDir` alatt.
- Ellenőrzi a parancs sikerességét a `Test-CommandSuccess` függvény segítségével.
- Ha a mappa létrehozása sikertelen, kivételt dob.

### 8. `Set-GitlabPassword`

**Leírás**: Beállítja a GitLab adminisztrátori jelszót.

**Működés**:

- Kéri a felhasználótól az adminisztrátori jelszót (alapértelmezett: `$Config.GitlabRootPassword`).
- Ha a jelszó üres, megtartja az alapértelmezettet.
- Ellenőrzi, hogy a jelszó megfelel-e a követelményeknek (legalább 8 karakter, tartalmaz nagybetűt, kisbetűt, számot és speciális karaktert).
- Ha a jelszó nem felel meg, hibaüzenetet ír ki, és újrapróbálkozik.
- Sikeres beállítás esetén frissíti a `$Config.GitlabRootPassword` értékét.

### 9. `New-EnvironmentFile`

**Leírás**: Létrehozza a `.env` környezetfájlt a GitLab konfigurációjához.  
**Paraméterek**:

- `$Domain`: A GitLab domainje.

- `$Passwd`: Az adminisztrátori jelszó.

**Működés**:

- Létrehoz egy `.env` fájlt a szükséges környezeti változókkal (pl. konténer neve, URL, SSH port, jelszó, stb.).
- A fájlt UTF-8 kódolással menti a `$Paths.DotEnvFile` helyre.

### 10. `Set-GitlabEnvironment`

**Leírás**: Beállítja a GitLab környezetet a távoli szerveren.

**Működés**:

- A `New-EnvironmentFile` függvény segítségével létrehozza a `.env` fájlt.
- Az `Invoke-SCP` használatával feltölti a `.env` és `docker-compose.yml` fájlokat a távoli szerver `$Config.DockerDir` könyvtárába.
- Ellenőrzi a feltöltés sikerességét a `Test-CommandSuccess` függvény segítségével.

### 11. `Start-Gitlab`

**Leírás**: Elindítja a GitLab konténert a távoli szerveren.

**Működés**:

- Az `Invoke-SSH` használatával futtatja a `docker compose up -d` parancsot a távoli szerveren.
- Ellenőrzi a parancs sikerességét a `Test-CommandSuccess` függvény segítségével.

### 12. `Write-AccessInfo`

**Leírás**: Kiírja a GitLab hozzáférési információkat.

**Működés**:

- Megjeleníti a web, webalkalmazás és GitLab URL-eket.
- Kiírja az adminisztrátori felhasználónevet és jelszót.
- Figyelmeztetést ad a jelszó mielőbbi megváltoztatására.
- Tájékoztat, hogy a GitLab indítása eltarthat néhány percig.

### 13. `Setup-Gitlab`

**Leírás**: Összefogja a GitLab telepítési lépéseit.

**Működés**:

- Hívja a következő függvényeket:

  - `New-GitlabDirectories`
  - `Set-GitlabPassword`
  - `Set-GitlabEnvironment`
  - `Start-Gitlab`

- Hibakezelés: Ha bármelyik lépés sikertelen, hibát ír ki.

## Hibakezelés

- A szkript több helyen használ hibakezelést (`try-catch` blokkok).
- Ha egy parancs sikertelen (pl. SSH kulcs generálás, mappa létrehozás), a szkript hibaüzenetet ír ki, és adott esetben leáll.
- A `Test-CommandSuccess` függvény minden külső parancs sikerességét ellenőrzi, és részletes visszajelzést ad.

---
