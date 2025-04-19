# MikroTik forgalomirányító konfiguráló szkriptek

## A `values.ps1` használata

Ennek a szkriptnek a módosításával meg lehet határozni a `setup.ps1` számára szükséges változókat.

**Alap beállítások**

```ps1
# A MikroTik forgalomirányító külső címe
$RouterExternalAddress = '10.0.0.128'

# A MikroTik forgalomirányító admin felhasználójának jelszava
$RouterPassword = 'lalilulelo'
```

## A `setup.ps1` használata

```
./setup.ps1 <Művelet> [Paraméterek]
```

### Műveletek

| Művelet    | Leírás                                                                                                            |
| ---------- | ----------------------------------------------------------------------------------------------------------------- |
| `Help`     | Használati útmutató kiíratása.                                                                                    |
| `CopyKey`  | Hozzáadja a legelső megfelelő publikus SSH kulcsot forgalomirányító megadott felhasználója elfogadott kulcsaihoz. |
| `CopyConf` | Felmásolja a [konfigurációs fájlokat](../../config/router/) a forgalomirányítóra.                                 |
| `SetConf`  | Lefuttatja a felmásolt konfigurációs fájlokat a forgalomirányítón.                                                |
| `SetPass`  | Beállítja a megadott felhasználó jelszavát a forgalomirányítón.                                                   |
| `Full`     | Lefuttatja a `CopyKey`, `CopyConf`, `SetConf` és `SetPass` műveleteket.                                           |
| `SSH`      | Rákapcsolódik a forgalomirányítóra SSH-n keresztül.                                                               |
| `TestConn` | Leteszteli, hogy valamelyik címen elérhető-e a forgalomirányító.                                                  |

### Opcionális paraméterek

| Paraméter   | Leírás                                    |
| ----------- | ----------------------------------------- |
| `-Address`  | Felülírja a használandó IP címet.         |
| `-Port`     | Felülírja a használandó SSH portot.       |
| `-User`     | Felülírja a használandó felhasználónevet. |
| `-Password` | Felülírja a használandó jelszavat.        |
