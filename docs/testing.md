### 2.7. Tesztelési terv

A rendszer működésének ellenőrzésére az alábbi teszteket kell elvégezni:

- **Hálózati tesztek**:

  - **T1**: DHCP kiosztás ellenőrzése (szerver és kliensek IP-címei).
  - **T2**: DNS feloldás tesztelése (`ping boilerplate.hu`, `ping gitlab.boilerplate.hu`).
  - **T3**: WireGuard VPN kapcsolat tesztelése külső hálózatról.
  - **T4**: Porttovábbítás ellenőrzése (443-as port elérése az internetről).

- **Szerver tesztek**:

  - **T5**: Docker konténerek indítása és elérhetősége (`docker ps`, `curl http://192.168.11.11`).
  - **T6**: GitLab működésének ellenőrzése (bejelentkezés, repó létrehozása).
  - **T7**: Nginx reverse proxy tesztelése (domainek elérése: `boilerplate.hu`, `gitlab.boilerplate.hu`).
  - **T8**: SSH hozzáférés ellenőrzése VPN-en keresztül.

- **Kliens tesztek**:

  - **T9**: GitLab elérése mindkét kliensről (böngésző és `git clone` parancs).
  - **T10**: Docker konténer futtatása a klienseken (pl. `docker run hello-world`).
  - **T11**: Helyi fejlesztési környezet tesztelése (kód írása, commit, push).

- **Biztonsági tesztek**:
  - **T12**: SSH hozzáférés korlátozásának ellenőrzése (VPN nélkül nem működik).
  - **T13**: Tűzfal szabályok tesztelése (csak a 443 és 7172 portok érhetők el kívülről).
