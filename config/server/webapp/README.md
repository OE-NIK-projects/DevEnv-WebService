# Webapp

Ez egy modern webalkalmazás, amelyet a Bun futásidejű környezetben fejlesztettek.

## Követelmények

- **Bun**: v1.2.4 vagy újabb (Ez a projekt a `bun init` paranccsal készült)
- **TypeScript**: ^5 verzió (peer dependency)

## Telepítés

A függőségek telepítéséhez futtasd a következő parancsot:

```bash
bun install
```

Ez telepíti a projekt futtatásához szükséges összes függőséget.

## Futtatás

### Éles környezetben

Az alkalmazás elindításához:

```bash
bun run start
```

vagy közvetlenül:

```bash
bun run index.ts
```

### Fejlesztési módban

A fejlesztési mód indítása élő újratöltéssel (hot reload):

```bash
bun run dev
```

Ez a `DEVMODE=true` környezeti változóval fut, amely lehetővé teszi a fejlesztési funkciókat és az élő újratöltést.

## Build

A projekt buildelése a `./build` mappába:

```bash
bun run build
```

Ez egy optimalizált verziót készít az `index.ts` fájlból.

A [Bun](https://bun.sh) egy gyors, mindent egyben tartalmazó JavaScript futásidejű környezet, amely egyesíti a csomagkezelőt, a bundlert és a futtatókörnyezetet.

## Fejlesztői függőségek

- `@types/bun`: TypeScript definíciók a Bun-hoz

## Megjegyzések

- A projekt privátként van jelölve a `package.json`-ban (`"private": true`).
- A fő belépési pont az `index.ts` fájl (`"module": "index.ts"`).
