# M06-01 — count y for_each

[← Página anterior](README.md) · [Siguiente página →](M06-02-locals-condicionales.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Generar varios recursos a partir de un mapa con `for_each` y crear un recurso opcional con `count`.
Todo con `plan`, sin aplicar: no consume AWS.

### Prerrequisitos

- Dev container (M01). Material base en `labs-sandbox/m06/` (o crea el directorio tú mismo).

### En qué consiste

Defines un mapa de buckets y dejas que `for_each` los genere; añades un recurso on/off con `count`.

### 1 — Define los datos

**Acción:** En `labs-sandbox/m06/main.tf`:

```hcl
variable "project" {
  type    = string
  default = "tfadv"
}

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  prefix = "${var.project}-${var.environment}"

  buckets = {
    logs = { versioning = false }
    data = { versioning = true }
    tmp  = { versioning = false }
  }
}
```

**Por qué:** Los datos (qué buckets quieres) quedan separados de la lógica que los crea.
**Resultado esperado:** Un mapa `buckets` con tres entradas.

### 2 — Genera recursos con for_each

**Acción:**

```hcl
resource "aws_s3_bucket" "this" {
  for_each = local.buckets
  bucket   = "${local.prefix}-${each.key}"
}
```

**Por qué:** Un solo bloque crea N buckets, anclados a su clave.
**Resultado esperado:** El `plan` propone `this["logs"]`, `this["data"]`, `this["tmp"]`.

### 3 — Añade un recurso condicional con count

**Acción:**

```hcl
variable "create_inventory" {
  type    = bool
  default = false
}

resource "aws_s3_bucket" "inventory" {
  count  = var.create_inventory ? 1 : 0
  bucket = "${local.prefix}-inventory"
}
```

**Por qué:** `count` con un booleano es el patrón correcto para "crear o no" un recurso.
**Resultado esperado:** Con el default `false`, el `plan` no incluye el bucket de inventario.

### 4 — Valida y revisa el plan

**Acción:**

```bash
cd labs-sandbox/m06
terraform fmt
terraform init -backend=false
terraform plan
terraform plan -var "create_inventory=true"
```

**Por qué:** Ves cómo `for_each` genera por clave y cómo el condicional añade el recurso extra.
**Resultado esperado:** El primer `plan` lista 3 buckets; el segundo añade `inventory[0]`.

## Comprueba tu entendimiento

**Generación por clave**
Ejecuta `terraform plan`.
→ Aparecen `aws_s3_bucket.this["logs"]`, `["data"]` y `["tmp"]`.

**El condicional funciona**
Ejecuta `terraform plan -var "create_inventory=true"`.
→ El `plan` añade `aws_s3_bucket.inventory[0]`.

## Reto

### 1 — De lista a mapa

Te dan los nombres como **lista**: `["logs","data","tmp"]`. ¿Cómo los usarías con `for_each` sin
sufrir el problema de los índices de `count`?

<details>
<summary>Ver solución</summary>

Conviértela en set con `toset(var.nombres)` y usa `for_each = toset(var.nombres)`, accediendo con
`each.value`. Así cada recurso se ancla a su valor, no a un índice posicional.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Invalid for_each argument` | Pasaste una lista en vez de mapa/set | Usa `toset(...)` o un mapa |
| Recursos recreados al reordenar | Usaste `count` sobre una lista | Cambia a `for_each` con claves estables |
| `plan` pide credenciales AWS | Hiciste `apply` en vez de `plan` | Quédate en `plan`; con `init -backend=false` basta |
