# M05-01 — Versionado y distribución

[← Página anterior](README.md) · [Siguiente página →](../M06-expresiones-avanzadas/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Publicar el módulo S3 (de M04) en un repo, etiquetarlo `v1.0.0`, consumirlo por `ref`, publicar
`v1.1.0` y actualizar de forma controlada. Es trabajo de Git: no consume AWS.

### Prerrequisitos

- El módulo S3 de M04 y un repositorio (o subcarpeta) donde publicarlo.

### En qué consiste

Versionas un módulo con tags y demuestras que el consumidor controla cuándo adopta cada versión.

### 1 — Publica el módulo y etiqueta v1.0.0

**Acción:**

```bash
git tag v1.0.0
git push origin v1.0.0
```

**Por qué:** El tag congela un punto exacto del código como versión consumible.
**Resultado esperado:** El tag `v1.0.0` aparece en GitHub.

### 2 — Consume el módulo por referencia

**Acción:** En el entorno consumidor, apunta el `source` a la versión:

```hcl
module "bucket" {
  source      = "git::https://github.com/tu-usuario/terraform-modules.git//s3?ref=v1.0.0"
  bucket_name = "${var.project}-${var.environment}-data"
  tags        = { ManagedBy = "terraform" }
}
```

**Por qué:** Fijas la versión exacta; nadie te cambia el módulo bajo los pies.
**Resultado esperado:** `terraform init` descarga el módulo en `v1.0.0`.

> [!TIP]
> El doble slash `//s3` indica la **subcarpeta** del módulo dentro del repo; `?ref=` fija el tag.

### 3 — Publica una nueva versión (cambio compatible)

**Acción:** Añade un input opcional al módulo (p. ej. `force_destroy` con default `false`), commitea y:

```bash
git tag v1.1.0
git push origin v1.1.0
```

**Por qué:** Es funcionalidad nueva compatible → sube **MINOR**.
**Resultado esperado:** Conviven `v1.0.0` y `v1.1.0`.

### 4 — Actualiza el consumidor de forma controlada

**Acción:** Cambia la `ref` a `v1.1.0` y reinicializa:

```bash
terraform init -upgrade
terraform plan
```

**Por qué:** La actualización ocurre **cuando tú decides**, no automáticamente.
**Resultado esperado:** `init -upgrade` trae `v1.1.0`; `plan` muestra solo lo que cambia.

## Comprueba tu entendimiento

**La versión está fijada**
Mira el `source` del módulo en el consumidor.
→ Incluye `?ref=v1.0.0` (o la versión vigente), no `main`.

**Conviven versiones**
Ejecuta `git tag` en el repo del módulo.
→ Aparecen `v1.0.0` y `v1.1.0`.

## Reto

### 1 — Rango de versiones en el Terraform Registry

Si publicaras el módulo en el Terraform Registry en vez de Git, ¿cómo permitirías "cualquier 1.x
pero no 2.0"?

<details>
<summary>Ver solución</summary>

Con un módulo del Registry usas el argumento `version` y restricciones: `version = "~> 1.0"`
(admite `>=1.0, <2.0`). Así recibes parches y minors compatibles, pero no el MAJOR que podría
romper. (Con `source` de Git se fija por `ref`, sin rangos.)

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `terraform init` no ve la nueva versión | El módulo quedó cacheado | Usa `terraform init -upgrade` |
| `Could not download module` | `ref` o subcarpeta `//` mal escritos | Revisa la URL, el `//subdir` y el `?ref=` |
| El consumidor cambió sin querer | Apuntabas a `main` | Pinea a un tag `?ref=vX.Y.Z` |
| Confusión MAJOR/MINOR | Cambio incompatible publicado como MINOR | Si rompes la interfaz, sube **MAJOR** |
