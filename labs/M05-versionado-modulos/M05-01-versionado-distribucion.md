# M05-01 — Versionado y distribución

[← Página anterior](README.md) · [Siguiente página →](../M06-expresiones-avanzadas/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Publicar el módulo S3 (de M04) en un repo, etiquetarlo `v1.0.0`, consumirlo por `ref`, publicar
`v1.1.0` y actualizar de forma controlada. Es trabajo de Git: no consume AWS.

### Prerrequisitos

- El módulo S3 de M04 (o el material base en `labs-sandbox/m05/`).
- Dev container (M01). Este lab **no consume AWS**: basta `init`/`validate`/`plan`.

### Material del laboratorio

En el repo hay una carpeta lista para demo y práctica:

```
labs-sandbox/m05/
├── publisher/s3/          ← módulo a publicar (autor)
├── publisher/snippets/      ← snapshot v1.0.0 para comparar
└── consumer/                ← entorno que consume el módulo por source + ref
```

Consulta `labs-sandbox/m05/README.md` para el guion de demostración del formador.

### En qué consiste

Versionas un módulo con tags y demuestras que el consumidor controla cuándo adopta cada versión.

### 1 — Publica el módulo y etiqueta v1.0.0

**Acción:** Parte de `labs-sandbox/m05/publisher/s3/` (o tu módulo S3 de M04). Cuando la interfaz
esté estable (sin `force_destroy`), crea el tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

**Por qué:** El tag congela un punto exacto del código como versión consumible.
**Resultado esperado:** El tag `v1.0.0` aparece en GitHub.

> En el sandbox del curso puedes usar tags con prefijo `m05-s3-v1.0.0` para no chocar con otros
> módulos. Ver `labs-sandbox/m05/publisher/README.md`.

### 2 — Consume el módulo por referencia

**Acción:** En `labs-sandbox/m05/consumer/main.tf` (o tu entorno consumidor), apunta el `source`:

```hcl
module "bucket" {
  # Demo local (sin Git):
  source = "../publisher/s3"

  # Remoto con versión fijada:
  # source = "git::https://github.com/tu-usuario/terraform-modules.git//s3?ref=v1.0.0"

  bucket_name = "${var.project}-${var.environment}-data"
  tags        = var.common_tags
}
```

Luego:

```bash
cd labs-sandbox/m05/consumer
terraform init
terraform validate
```

**Por qué:** Fijas la versión exacta con `?ref=`; nadie te cambia el módulo bajo los pies.
**Resultado esperado:** `terraform init` descarga el módulo en `v1.0.0` (o resuelve la ruta local).

> [!TIP]
> El doble slash `//s3` indica la **subcarpeta** del módulo dentro del repo; `?ref=` fija el tag.

### 3 — Publica una nueva versión (cambio compatible)

**Acción:** En `publisher/s3/main.tf` añade `force_destroy` (input opcional, default `false`) — ya
está en el sandbox como ejemplo v1.1.0. Commitea y:

```bash
git tag v1.1.0
git push origin v1.1.0
```

**Por qué:** Es funcionalidad nueva compatible → sube **MINOR**.
**Resultado esperado:** Conviven `v1.0.0` y `v1.1.0`.

### 4 — Actualiza el consumidor de forma controlada

**Acción:** En `consumer/main.tf`, cambia la `ref` a `v1.1.0` (o descomenta el `source` remoto) y
reinicializa:

```bash
cd labs-sandbox/m05/consumer
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
