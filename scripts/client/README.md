# Fejlesztői Eszközök Telepítő

Ez egy PowerShell szkript, amely a winget segítségével alapvető fejlesztői eszközöket, konfigurálja a git-et és egy root CA tanúsítványt telepít.

## Előfeltételek

- Telepített Windows 11
- Telepített `winget` (elérhető a Microsoft Store-ban az App Installer alkalmazáson keresztül)
- A PowerShell végrehajtási házirendjének engedélyeznie kell a távoli szkriptek futtatását:

  ```ps1
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
  ```

## Használat

Futtassuk a következő parancsot PowerShell-ben (Rendszergazdai jogosultsággal):

```ps1
irm https://raw.githubusercontent.com/OE-NIK-projects/DevEnv-WebService/refs/heads/main/scripts/client/Developer-Tools-Installer.ps1 | iex
```

## Telepített Eszközök

- **Google Chrome**: Webböngésző
- **Windows Terminal**: Modern terminál alkalmazás
- **Visual Studio Code**: Kódszerkesztő
- **Node.js**: JavaScript futtatókörnyezet
- **Git**: Verziókezelő rendszer
- **GitHub Desktop**: GitHub grafikus kliens
- **VLC**: Médialejátszó
- **Python 3.13**: Programozási nyelv
- **Postman**: API tesztelő eszköz
- **Docker Desktop**: Konténerizációs platform
- **WSL2**: Windows alrendszer Linuxhoz (újraindítást igényelhet)
- **Root CA Tanúsítvány**: Telepíti a megadott root CA tanúsítványt a Local Machine Root tárolóba a https://raw.githubusercontent.com/OE-NIK-projects/DevEnv-WebService/refs/heads/main/config/certs/rca.crt címről

## Testreszabás

Töltsük le és szerkesszük az `Developer-Tools-Installer.ps1` fájlban található `$programs` tömböt az eszközlista módosításához.
