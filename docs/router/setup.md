# MikroTik Router Beállítása

**[↩ Vissza](README.md)**

### Tartalom jegyzék

0. [Előkövetelmények](#előkövetelmények)
1. [VMWare virtuális hálózatok beállítása](#1-vmware-virtuális-hálózatok-beállítása)
2. [MikroTik CHR telepítése VMWare-be](#2-mikrotik-chr-telepítése-vmware-be)
3. [Szükséges változókat beállítása a values.ps1 fájlban](#3-szükséges-változókat-beállítása-a-valuesps1-fájlban)
4. [A setup.ps1 szkript futtatása](#4-a-setupps1-szkript-futtatása)
5. [MikroTik CHR license aktiválása](#5-mikrotik-chr-license-aktiválása-opcionális-de-ajánlott)


## Előkövetelmények

- [OpenSSH](https://www.openssh.com/)
- [PowerShell 7+](https://github.com/PowerShell/PowerShell/)
- VMWare Workstation
- [WireGuard](https://www.wireguard.com/install/)


## 1. VMWare virtuális hálózatok beállítása

1. Nyissuk meg a virtuális hálózat szerkeztőt az `Edit`>`Virtual Machine Editor` menüponttal.

2. Állítsuk be a `vmnet1`-et az alábbiak alapján!
![vmnet1](img/1/vmnet1.png)

3. Állítsuk be a `vmnet8`-at az alábbiak alapján!
![vmnet8](img/1/vmnet8.png)

## 2. MikroTik CHR telepítése VMWare-be

> Hivatalos segédlet: https://help.mikrotik.com/docs/spaces/ROS/pages/18350234/Cloud+Hosted+Router+CHR

1. Töltsük le a legfrissebb 7.18-as Cloud Hosted Router **vmdk** lemezképet a [MikroTik weboldaláról](https://mikrotik.com/download) majd tömörítsük ki a zip archívumból a `.vmdk` fájlt egy tetszőleges helyre!<br><br>
![01](img/2/01.png)<br><br>

2. Hozzunk létre egy új virtuális gépet a VMWare-be! Ezt megtehetjük a `File`>`New Virtual Machine...` menüponttal.<br><br>

3. Válasszuk ki a `Custom` konfigurációt!
![03](img/2/03.png)

4. Az alapértelemezett beállítások megfelelnek, továbbléphetünk.
![04](img/2/04.png)

5. Válasszuk ki azt, hogy majd később telepítünk operációs rendszert!
![05](img/2/05.png)

6. Válasszuk ki az `Other`/`Other 64-bit` verziót!
![06](img/2/06.png)

7. Állítsunk be egy nevet az új virtuális gépnek!
![07](img/2/07.png)

8. Állítsunk be egy processzor magot.
![08](img/2/08.png)

9. Állítsunk be legalább 256 MB RAM-ot.
![09](img/2/09.png)

10. A hálózati beállításokkal majd később foglalkozunk.
![10](img/2/10.png)

11. Válasszuk az ajánlott opciót!
![11](img/2/11.png)

12. Válasszuk az ajánlott opciót!
![12](img/2/12.png)

13. Válasszuk ki, hogy egy már létező lemezt szeretnénk használni!
![13](img/2/13.png)

14. Válasszuk ki a kitömörített `.vmdk` fájlt!
![14](img/2/14.png)

15. Nyomjunk rá a `Customize Hardware...` gombra!
![15](img/2/15.png)

16. Adjunk a virtuális géphez két hálózati interfészt. Az első a `vmnet8`-at, a második a `vmnet1`-et használja!
![16](img/2/16.png)

17. Zárjuk be ezt az ablakot és fejezzük be a virtuális gép létrehozását!

18. Indítsuk el a virtuális gépet!<br><br>
![18](img/2/18.png)<br><br>


## 3. Szükséges változókat beállítása a [values.ps1](../../config/scripts/router/values.ps1) fájlban

### Példa
```ps1
# A MikroTik router admin felhasználó jelszava
$RouterPassword = 'lalilulelo'

# A MikroTik router külső címe
$RouterExternalAddress = '10.0.0.128'
```

> Alap esetben a MikroTik router DHCP segítségével próbál címet választani a WAN interfészen.


## 4. A [setup.ps1](../../config/scripts/router/setup.ps1) szkript futtatása

> Az útvonalak a repo gyökeréhez képest vannak meghatározva.

### Szkript instrukciók kiíratása
```sh
config/scripts/router/setup.ps1 Help
```

### Szkript futtatása
```sh
config/scripts/router/setup.ps1 Full
```

### Példa
![full](img/4/full.png)

## 5. MikroTik CHR license aktiválása (opcionális, de ajánlott)

MikroTik CHR eszközöknél lehetőség van 60 napos próbalecenszek igénylésre. Ehhez egy MikroTik fiók szükséges!

> A router sebessége limitálva van license nélkül.

További információért keresse fel a [MikroTik dokumentációt](https://help.mikrotik.com/docs/spaces/ROS/pages/18350234/Cloud+Hosted+Router+CHR#CloudHostedRouter,CHR-Freelicenses).


---
**[↑ Lap teteje](#mikrotik-router-beállítása)**\
**[↩ Vissza](README.md)**
