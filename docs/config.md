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
