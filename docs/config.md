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

Lépjünk be a `DevEnv-WebService/config/gitlab-docker-setup` mappába:

```bash
cd DevEnv-WebService/config/gitlab-docker-setup
```

## Automatikus Konfiguráció

A lépések az **[Ansible dokumentáció](./ansible.md)**-ban vannak részletezve.
