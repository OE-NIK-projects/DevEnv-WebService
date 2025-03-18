# Windows 10 Kliens Telepítése

A Windows 10 kliens telepítése alapértelmezett beállításokkal történt, és az alábbi szoftverek kerültek telepítésre:

## Felhasználó és Belépés

- **Felhasználó neve**: WindowsClient
- **Felhasználói kód**: Clientdemo

A felhasználói fiók a rendszer alapértelmezett beállításai szerint lett konfigurálva, és a `Clientdemo` jelszóval történik a belépés.

## Alapértelmezett Telepítés

A telepítés a Windows 10 legfrissebb verzióján alapul. Az operációs rendszer az alapértelmezett beállításokkal lett telepítve, nincsenek különleges konfigurációk, és minden alapértelmezett nyelvi beállításon maradt.

## Telepített szoftverek

Az alábbi szoftverek kerültek telepítésre a kliens gépre:

- **VS Code**: Kódíró környezet a fejlesztéshez.
- **Visual Studio**: Fejlesztői környezet, amely több programozási nyelvet is támogat.
- **Git**: Verziókezelő rendszer.
- **GitHub Desktop**: Grafikus felhasználói felület, amely lehetővé teszi a felhasználók számára, hogy könnyedén kezeljék és szinkronizálják a GitHub tárolóikat anélkül, hogy parancssort kellene használniuk.
- **Zoom**: Videokonferencia szoftver.
- **GIMP**: Nyílt forráskódú képszerkesztő program.
- **Docker Desktop**: Lehetővé teszi a fejlesztők számára, hogy egyszerűen kezeljék a Docker konténereket és a virtuális gépeket, valamint fejlesszenek, teszteljenek és futtassanak szoftverekat konténerizált környezetben. 
- **WireGuard**: VPN szoftver.



## Telepítési Folyamat

A telepítés során az alapértelmezett beállításokat választottuk a Windows 10 operációs rendszer telepítéséhez, beleértve a rendszerfrissítéseket és a szükséges drivereket. A telepítést követően a szükséges fejlesztői és egyéb eszközöket az alábbi lépések szerint telepítettük:

### Telepítés Lépései

1. **VS Code**: A legfrissebb verziót telepítettük a hivatalos weboldalról.
2. **Visual Studio**: A szükséges fejlesztői eszközök és nyelvek kiválasztásával telepítettük.
3. **Git**: A Git hivatalos weboldaláról töltöttük le és telepítettük.
4. **GitHub Desktop**: A GitHub Desktop klienst a GitHub hivatalos oldaláról telepítettük.
5. **Zoom**: A Zoom legfrissebb verzióját a hivatalos oldalon található telepítő segítségével telepítettük.
6. **GIMP**: A képszerkesztő szoftvert az ingyenes verzióban a GIMP hivatalos oldaláról telepítettük.
7. **Docker Desktop**: A Docker Desktop telepítéséhez a hivatalos Docker weboldalán található telepítőt használtuk.
8. **WireGuard**: A VPN szoftvert a hivatalos WireGuard weboldalról telepítettük.

## Telepítés utáni Lépések

- A telepítés után szükséges konfigurálni minden szoftvert az egyéni igények szerint.
- A rendszer további beállításait a projekt követelményeinek megfelelően kell finomítani.

##


# Ubuntu Kliens Telepítése

Az Ubuntu kliens telepítése alapértelmezett beállításokkal történt, és az alábbi szoftverek kerültek telepítésre:

## Alapértelmezett Telepítés

A telepítés az Ubuntu legfrissebb stabil verzióján alapul. Az operációs rendszer az alapértelmezett beállításokkal lett telepítve, nincsenek különleges konfigurációk, és minden alapértelmezett nyelvi beállításon maradt.



## Telepített Szoftverek

Az alábbi szoftverek kerültek telepítésre a kliens gépre az Ubuntu Store-on keresztül:

- **VS Code**: Fejlesztői környezet kódíráshoz.
- **GitKraken**: Verziókezelő kliens GitHub és Git számára.
- **Darktable**: Nyílt forráskódú fotószerkesztő és nyers képkezelő.
- **Brave Web Browser**: Biztonságos és reklámmentes böngésző.
- **Ferdium**: Lehetővé teszi több üzenetküldő és webes szolgáltatás egyetlen felületen történő kezelését.
- **GIMP**: Képszerkesztő szoftver.
- **Shotcut**: Nyílt forráskódú videószerkesztő.
- **Zoom**: Videokonferencia szoftver.
- **LibreOffice**: Teljes funkcionalitású irodai programcsomag.
- **WireGuard**: VPN szoftver.


## Docker és Docker Compose Telepítése

A Docker és Docker Compose manuálisan került telepítésre a következő verziókkal:

- **Docker**: 28.0.1
- **Docker Compose**: 2.34.0

### Docker Telepítési Lépései

1. Frissítjük a csomagtárolókat és telepítjük a szükséges csomagokat:
   ```sh
   sudo apt update
   sudo apt install apt-transport-https ca-certificates curl software-properties-common
   ```
2. Hozzáadjuk a Docker hivatalos GPG kulcsát:
   ```sh
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
   ```
3. Hozzáadjuk a Docker tárolót a csomagkezelőhöz:
   ```sh
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
   ```
4. Frissítjük újra a csomaglistát és telepítjük a Docker Engine-t:
   ```sh
   sudo apt update
   sudo apt install docker-ce
   ```
5. Ellenőrizzük, hogy a Docker sikeresen települt-e:
   ```sh
   sudo docker --version
   ```
6. Indítjuk és engedélyezzük a Docker automatikus indítását:
   ```sh
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

### Docker Compose Telepítési Lépései

1. Letöltjük a Docker Compose legfrissebb verzióját:
   ```sh
   sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   ```
2. Futtathatóvá tesszük a fájlt:
   ```sh
   sudo chmod +x /usr/local/bin/docker-compose
   ```
3. Ellenőrizzük a telepítést:
   ```sh
   docker-compose --version
   ```


## Következő Lépések

- A telepítés után szükséges konfigurálni minden alkalmazást az egyéni igények szerint.
- A rendszer további beállításait a projekt követelményeinek megfelelően kell finomítani.

