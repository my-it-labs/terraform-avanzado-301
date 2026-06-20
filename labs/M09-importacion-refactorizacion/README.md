# M09 — Importación y refactorización

[← Página anterior](../M08-terraform-cloud/M08-01-migracion-terraform-cloud.md) · [Siguiente página →](M09-01-importar-recursos.md)

> [!NOTE]
> **Cómo funciona este módulo.** Primero la **teoría**, luego la **demostración guiada** del
> formador, y después **practicas tú** en los laboratorios (este módulo tiene dos).

## Qué aprenderás

- Traer recursos existentes (creados a mano) bajo gestión de Terraform con `import`.
- Refactorizar código (renombrar, mover a módulos) **sin recrear** recursos usando `moved`.

## Teoría

| Situación | Herramienta |
|-----------|-------------|
| Un recurso existe en AWS pero no en tu estado | `terraform import` (o bloque `import`) |
| Renombras/mueves un recurso ya gestionado | bloque `moved` (en el código, versionable) |

> [!IMPORTANT]
> `import` solo trae el recurso al **estado**; tú debes escribir el código `.tf` que lo describe.
> Si el código no coincide con la realidad, el siguiente `plan` querrá "corregir" diferencias.

El bloque `moved` es la evolución de `state mv` (M07): vive en el código, se revisa en el PR y se
aplica solo, sin comandos manuales.

```hcl
moved {
  from = aws_s3_bucket.data
  to   = aws_s3_bucket.primary
}
```

## Demostración guiada

> Recorrido del formador. Requiere recursos reales (🔴 AWS): hazlo en la sesión y destruye al final.

1. **Crear "a mano" e importar.** Se crea un bucket por consola, se escribe su bloque `resource` y
   se hace `import`; luego `plan` debe decir **No changes** si el código casa con la realidad.
2. **Refactor con moved.** Se renombra un recurso en el código y se añade un bloque `moved`;
   `plan`/`apply` aplican el movimiento sin destruir nada.
3. **Mover a módulo.** Se muestra cómo `moved` también sirve para meter un recurso dentro de un
   módulo (`module.x.aws_...`) sin recrearlo.

## Ahora practica tú

| Lab | Título | Qué harás |
|-----|--------|-----------|
| M09-01 | [Importar recursos existentes](M09-01-importar-recursos.md) | Crear un bucket a mano y traerlo al estado con `import` |
| M09-02 | [Refactor con moved](M09-02-refactor-moved.md) | Renombrar y mover un recurso a un módulo sin recrearlo |

→ Empieza por **[M09-01 — Importar recursos existentes](M09-01-importar-recursos.md)**.
