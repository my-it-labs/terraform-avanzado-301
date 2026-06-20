# M03 — Git aplicado a IaC

[← Página anterior](../M02-organizacion-proyectos/M02-01-estructura-multientorno.md) · [Siguiente página →](M03-01-flujo-pull-request.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en el laboratorio.

## Qué aprenderás

- Trabajar Terraform en **flujo colaborativo**: ramas, Pull Requests y revisión de código.
- Distinguir conflictos de **código** de conflictos de **estado**.
- Buenas prácticas de revisión de cambios de infraestructura.

## Teoría

En IaC el flujo de Git es el de cualquier proyecto serio, con un matiz importante:

| Elemento | Idea |
|----------|------|
| **Rama** | Aíslas tu cambio del código estable (`main`). |
| **Pull Request (PR)** | Propones el cambio para que alguien lo revise antes de mezclar. |
| **Revisión** | Otra persona valida el `plan` y el código antes del merge. |
| **Conflicto de código** | Dos ramas tocan las mismas líneas; se resuelve editando el archivo. |

> [!IMPORTANT]
> **Código vs estado.** El **código** (`.tf`) se mezcla con Git sin problema. El **estado**
> (`.tfstate`) NO: si dos personas aplican a la vez, no se resuelve "a mano", sino con estado
> remoto y bloqueo (M07 y M08). Confundir ambos es el error clásico.

## Demostración guiada

> Recorrido del formador entre el editor y GitHub. Es trabajo de Git: no consume AWS.

1. **Rama por cambio.** Se crea una rama (`feature/...`) para aislar el cambio de `main`.
2. **PR + revisión.** Se sube la rama, se abre el Pull Request y se revisa el diff (y el `plan` en
   módulos que tocan AWS). Ningún cambio llega a `main` sin pasar por aquí.
3. **Conflicto y resolución.** Se simula que `main` cambió la misma línea: aparece el conflicto de
   código (`<<<<<<<`/`=======`/`>>>>>>>`) y se resuelve editando y confirmando.
4. **Estado ≠ código.** Se recalca por qué el `.tfstate` no se mezcla a mano (se resolverá con
   remote state y locking en M07/M08).

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M03-01 | [Flujo de Pull Request](M03-01-flujo-pull-request.md) | Crear una rama, abrir un PR, revisarlo, resolver un conflicto y mergear |

→ Empieza por **[M03-01 — Flujo de Pull Request](M03-01-flujo-pull-request.md)**.
