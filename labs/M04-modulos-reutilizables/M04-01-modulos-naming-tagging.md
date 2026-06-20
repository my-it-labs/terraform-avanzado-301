# M04-01 — Módulos de naming y tagging

[← Página anterior](README.md) · [Siguiente página →](M04-02-modulo-s3-parametrizable.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Crear dos módulos base —nomenclatura y etiquetado— con inputs/outputs y consumirlos desde
`environments/dev`. Trabajo de diseño y validación local: no consume AWS.

### Prerrequisitos

- Estructura `environments/dev` (M02) y dev container (M01).

### En qué consiste

Defines `modules/naming` y `modules/tagging`, los consumes desde el entorno y validas con `plan`.

### 1 — Módulo de naming

**Acción:** Crea `modules/naming/main.tf`:

```hcl
variable "project"     { type = string }
variable "environment" { type = string }

output "prefix" {
  value = "${var.project}-${var.environment}"
}
```

**Por qué:** Centralizas la convención de nombres en un único sitio.
**Resultado esperado:** El módulo devuelve un `prefix` tipo `tfadv-dev`.

### 2 — Módulo de tagging

**Acción:** Crea `modules/tagging/main.tf`:

```hcl
variable "project"     { type = string }
variable "environment" { type = string }

variable "extra_tags" {
  type    = map(string)
  default = {}
}

output "tags" {
  value = merge({
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }, var.extra_tags)
}
```

**Por qué:** Etiquetado consistente en todos los recursos, con extensión opcional.
**Resultado esperado:** Devuelve un mapa de etiquetas combinable.

### 3 — Consume los módulos desde el entorno

**Acción:** En `environments/dev/main.tf`, añade:

```hcl
module "naming" {
  source      = "../../modules/naming"
  project     = var.project
  environment = var.environment
}

module "tags" {
  source      = "../../modules/tagging"
  project     = var.project
  environment = var.environment
}

output "name_prefix" { value = module.naming.prefix }
output "common_tags" { value = module.tags.tags }
```

**Por qué:** Demuestras cómo el entorno usa los módulos sin conocer su interior.
**Resultado esperado:** Los outputs reflejan el prefijo y las etiquetas.

### 4 — Inicializa y valida

**Acción:**

```bash
cd environments/dev
terraform init
terraform validate
terraform plan
```

**Por qué:** `init` registra los módulos; `validate`/`plan` confirman que la composición es correcta.
**Resultado esperado:** `plan` muestra `name_prefix = tfadv-dev` y las etiquetas comunes.

## Comprueba tu entendimiento

**Módulos registrados**
Ejecuta `terraform init`.
→ Aparecen `naming` y `tags` como inicializados.

**Outputs correctos**
Ejecuta `terraform plan`.
→ `name_prefix` es `tfadv-dev` y `common_tags` incluye `ManagedBy = "terraform"`.

## Reto

### 1 — Etiqueta extra solo en prod

¿Cómo añadirías una etiqueta `CostCenter` solo en el entorno prod sin tocar el módulo?

<details>
<summary>Ver solución</summary>

Pasa `extra_tags = { CostCenter = "..." }` al `module "tags"` únicamente en `environments/prod`. El
módulo hace `merge`, así que el resto de entornos no se ven afectados.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Module not installed` | No ejecutaste `init` tras añadir módulos | Lanza `terraform init` |
| `Unsupported argument` | Pasas un input que el módulo no declara | Revisa las `variable` del módulo |
| El `merge` no combina | Orden o tipos incorrectos | `merge(base, var.extra_tags)`; ambos mapas de strings |
