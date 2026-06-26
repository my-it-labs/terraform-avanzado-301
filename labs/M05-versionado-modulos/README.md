# M05 — Versionado y distribución de módulos

[← Página anterior](../M04-modulos-reutilizables/M04-02-modulo-s3-parametrizable.md) · [Siguiente página →](M05-01-versionado-distribucion.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en el laboratorio.

## Qué aprenderás

- Tratar un módulo como un **producto** con versiones y consumidores.
- Publicar módulos en Git y versionarlos con **tags** (Semantic Versioning).
- Consumir módulos remotos por referencia de versión y actualizarlos de forma controlada.

## Teoría

**Semantic Versioning (SemVer):** `MAJOR.MINOR.PATCH`.

| Cambias… | Subes… | Ejemplo |
|----------|--------|---------|
| Algo incompatible (rompes la interfaz) | **MAJOR** | `1.4.2 → 2.0.0` |
| Funcionalidad compatible (nuevo input opcional) | **MINOR** | `1.4.2 → 1.5.0` |
| Arreglo sin cambiar la interfaz | **PATCH** | `1.4.2 → 1.4.3` |

El consumidor fija la versión en el `source` del módulo. Así, aunque publiques `v2.0.0`, su
infraestructura no cambia hasta que él decide actualizar.

> [!IMPORTANT]
> Consumir un módulo desde `main` (sin `ref`) es pedir una rotura sorpresa: cualquier commit tuyo
> afecta a quien lo use. **Pinea siempre una versión.**

## Demostración guiada

> Recorrido del formador. Es trabajo de Git: no consume AWS. Material en `labs-sandbox/m05/`.

1. **Publicar y etiquetar.** Se publica el módulo en un repo y se crea el tag `v1.0.0`
   (`git tag` + `git push origin v1.0.0`).
2. **Consumir por referencia.** El `source` apunta a `git::https://...//s3?ref=v1.0.0`: el doble
   slash indica la subcarpeta, `?ref=` fija el tag.
3. **Nueva versión controlada.** Se añade un input opcional (cambio compatible → `v1.1.0`) y se
   muestra cómo el consumidor adopta la nueva versión con `terraform init -upgrade`, no antes.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M05-01 | [Versionado y distribución](M05-01-versionado-distribucion.md) | Etiquetar un módulo con SemVer, consumirlo por referencia y actualizarlo |

→ Empieza por **[M05-01 — Versionado y distribución](M05-01-versionado-distribucion.md)**.
