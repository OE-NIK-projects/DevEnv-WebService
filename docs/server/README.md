# Ubuntu Server

Ubuntu Server verzió: 24.04.2 LTS

**[Telepítési útmutató →](setup.md)**

## Alap felhasználó

| Név    | Jelszó | Csoportok    |
| ------ | ------ | ------------ |
| ubuntu | ubuntu | sudo, docker |

## Interfészek

| Név   | Cím           | CIDR |          |
| ----- | ------------- | ---- | -------- |
| ens33 | 192.168.11.11 | /24  | Statikus |

## Szolgáltatások

| Név    | Port | Engedélyezett hálózatok |
| ------ | ---- | ----------------------- |
| SSH    | 22   | 192.168.11.0/24         |
| Docker | \*   | 192.168.11.0/24         |

## Docker konténerek

| Név             | Port      |
| --------------- | --------- |
| Nginx           | 80        |
| Webapp          | nginx     |
| Gitlab          | 2424, 443 |
| Some monitoring | nginx     |

## Docker hálózatok

| Név            | Engedélyezett hálózatok |
| -------------- | ----------------------- |
| docker_default | 0.0.0.0/24              |

## Docker kötetek

| Konténer        | Elérési útvonal        | Elérési útvonal (Konténer) |
| --------------- | ---------------------- | -------------------------- |
| Nginx           | ~/docker/nginx         | /etc/nginx                 |
| Webapp          | ~/docker/webapp        | ?                          |
| Gitlab          | ~/docker/gitlab/config | /etc/gitlab                |
|                 | ~/docker/gitlab/logs   | /var/log/gitlab            |
|                 | ~/docker/gitlab/data   | /var/gitlab                |
| Some monitoring | ?                      | ?                          |

## Szkriptek

- [Távoli elérés] (Part of Deploy-Gitlab.ps1)
- [Alap szerver beállítások] (Part of Deploy-Gitlab.ps1)
- [Gitlab konfiguráció] (Part of Deploy-Gitlab.ps1)
- [Nginx konfiguráció] (Missing)
- [Webapp konfiguráció] (Missing, Bun)
- [Elérési/Bejelentkezési adatok] (Part of Deploy-Gitlab.ps1)
- [Docker compose](../../config/scripts/server/docker-compose.yml)
