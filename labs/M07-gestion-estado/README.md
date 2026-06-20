# M07 — Gestión avanzada del estado

[← Página anterior](../M06-expresiones-avanzadas/M06-02-locals-condicionales.md) · [Siguiente página →](M07-01-operar-estado.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en los laboratorios (este módulo tiene dos).

## Qué aprenderás

- Qué es el **state** y por qué es la pieza más delicada de Terraform.
- Operar el estado con `terraform state list/show/mv/rm`.
- Detectar y entender el **drift** (cambios hechos fuera de Terraform).

## Teoría

El **state** es el mapa entre tu código y los recursos reales: guarda qué `aws_s3_bucket.this`
corresponde a qué bucket de AWS. Sin él, Terraform no sabría qué actualizar o destruir.

| Comando | Para qué |
|---------|----------|
| `state list` | Ver qué recursos hay en el estado |
| `state show <addr>` | Inspeccionar los atributos de uno |
| `state mv <a> <b>` | Renombrar/mover en el estado **sin** tocar el recurso real |
| `state rm <addr>` | Sacar del estado **sin** destruir el recurso |

> [!WARNING]
> `state rm` **no** borra el recurso en AWS: lo "olvida". `terraform destroy` **sí** lo destruye.
> Confundirlos es una fuente clásica de incidencias.

**Drift** = la realidad y el estado dejaron de coincidir porque alguien cambió algo "a mano" en la
consola. `terraform plan` lo detecta como una diferencia que querría revertir.

## Demostración guiada

> Recorrido del formador. Requiere un recurso real (🟡 AWS): créalo y destrúyelo en la sesión.

1. **Inventario del estado.** Tras un `apply` mínimo, `state list` muestra los recursos y
   `state show` los atributos de uno.
2. **Renombrar sin recrear.** Se renombra un recurso en el código y, con `state mv`, se mueve en el
   estado para que el `plan` quede limpio (sin destruir/crear).
3. **Provocar drift.** Se cambia algo en la consola de AWS (p. ej. una etiqueta del bucket) y el
   `plan` lo detecta como diferencia: ahí se explica qué hacer (revertir o reconciliar el código).

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M07-01 | [Operar el estado](M07-01-operar-estado.md) | Inspeccionar el estado y renombrar un recurso con `state mv` sin recrearlo |
| M07-02 | [Análisis de drift](M07-02-analisis-drift.md) | Provocar un cambio fuera de Terraform y detectarlo con `plan` |

→ Empieza por **[M07-01 — Operar el estado](M07-01-operar-estado.md)**.
