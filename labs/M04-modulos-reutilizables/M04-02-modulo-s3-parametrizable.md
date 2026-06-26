# M04-02 — Módulo S3 parametrizable

[← Página anterior](M04-01-modulos-naming-tagging.md) · [Siguiente página →](../M05-versionado-modulos/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Encapsular un bucket S3 (con versionado opcional) en un módulo y componerlo con los de naming y
tagging. Validación con `plan` en el entorno del alumno; **`apply` no disponible** por límites IAM
del rol (ver paso 5).

### Prerrequisitos

- Haber hecho M04-01 (módulos `naming` y `tags` ya consumidos en `environments/dev`).
- Tener definido tu identificador de alumno en el `.env` como `AWS_LAB_USER` (M01), p. ej.
  `david.pestana`. Lo reutilizarás en Terraform como `lab_user`.

### En qué consiste

Defines `modules/s3` con inputs/outputs y lo conectas a los módulos de naming/tagging del entorno.

### 1 — Crea el módulo S3

**Acción:** Crea `modules/s3/main.tf`:

```hcl
variable "bucket_name" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "versioning" {
  type    = bool
  default = true
}

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

output "bucket_id"  { value = aws_s3_bucket.this.id }
output "bucket_arn" { value = aws_s3_bucket.this.arn }
```

**Por qué:** Encapsulas un bucket con versionado configurable, listo para reutilizar.
**Resultado esperado:** El módulo expone `bucket_id` y `bucket_arn`.

### 2 — Declara la variable `lab_user`

El nombre del bucket usa `var.lab_user`, pero esa variable **no viene de M02**: debes declararla
ahora. Debe coincidir con `AWS_LAB_USER` de tu `.env` (M01): es el prefijo que exige el rol del
laboratorio (`curso-<usuario>-*`).

**Acción:** En `environments/dev/variables.tf`, añade:

```hcl
variable "lab_user" {
  type        = string
  description = "Identificador del alumno (mismo valor que AWS_LAB_USER del .env)"
}
```

En `environments/dev/terraform.tfvars`, añade tu identificador:

```hcl
lab_user = "david.pestana"   # sustituye por tu AWS_LAB_USER
```

**Por qué:** Sin esta variable, `terraform validate`/`plan` fallan con
`Reference to undeclared input variable "lab_user"`. Con un valor distinto de `AWS_LAB_USER`, el
`apply` puede crear el bucket pero el rol no te dejará borrarlo o listarlo.
**Resultado esperado:** `terraform validate` pasa y el plan muestra un nombre tipo
`curso-david.pestana-data-us-east-2`.

### 3 — Compón con naming y tagging

**Acción:** En `environments/dev/main.tf`, añade:

```hcl
module "bucket" {
  source      = "../../modules/s3"
  bucket_name = "curso-${var.lab_user}-data-${var.aws_region}"
  tags        = module.tags.tags
}

output "bucket_id" { value = module.bucket.bucket_id }
```

**Por qué:** El nombre y las etiquetas vienen de los otros módulos: composición real.
**Resultado esperado:** El bucket usará un nombre coherente con la convención.

En el mismo `environments/dev/main.tf`, configura el **provider** para que Terraform asuma el rol
del lab (igual que `aws --profile lab`). Sin esto, `apply` usa el usuario IAM del `.env` y falla con
`AccessDenied`:

```hcl
provider "aws" {
  region  = var.aws_region
  profile = "lab" # asume lab-role-curso; requiere source scripts/load-env.sh (M01)
}
```

Antes de `apply`, comprueba la identidad:

```bash
source scripts/load-env.sh
./scripts/check-aws-identity.sh
```

→ El paso 2 del checker debe mostrar `assumed-role/lab-role-curso/...`.

### 4 — Inicializa y planifica

**Acción:**

```bash
cd environments/dev
terraform init
terraform plan
```

**Por qué:** Compruebas qué se crearía sin aplicar todavía.
**Resultado esperado:** `plan` propone crear el bucket con nombre y etiquetas correctos.

### 5 — Validación final (sin `apply` en el entorno del alumno)

En el rol del lab **no hay** lecturas `s3:GetBucket*` que exige el provider AWS **5.x** al gestionar
un `aws_s3_bucket`. **No podemos ampliar esa política IAM** en el curso. Por tanto:

> [!IMPORTANT]
> **`terraform apply` y `terraform destroy` no están disponibles para el alumno** en M04-02.
> El objetivo del lab se cumple con **`init` + `validate` + `plan`**.

**Acción:**

```bash
source scripts/load-env.sh
cd environments/dev
terraform init
terraform validate
terraform plan
```

**Por qué:** El `plan` demuestra composición de módulos, nombre `curso-<usuario>-*` y etiquetas.
No necesitas crear el bucket en AWS para aprobar el ejercicio.
**Resultado esperado:** El plan propone 2 recursos (bucket + versionado) con nombre y tags correctos.

**Demo del formador (opcional):** el formador puede hacer un `apply` en vivo con credenciales que
sí tengan lecturas `GetBucket*`, solo para enseñar el flujo. Los alumnos no lo replican.

Si algún alumno probó `apply` y falló con `GetBucketWebsite` teniendo `assumed-role/...` en el
error, **no es un fallo suyo**. Si quedó un bucket a medias:

```bash
aws --profile lab s3api head-bucket --bucket curso-<usuario>-data-us-east-2
aws --profile lab s3 rb s3://curso-<usuario>-data-us-east-2 --force   # solo si existe
terraform state rm module.bucket.aws_s3_bucket_versioning.this        # solo si hay estado
terraform state rm module.bucket.aws_s3_bucket.this
```

### Permisos del rol del laboratorio

En el curso operas con **mínimo privilegio** (`LabRole-curso`, perfil `lab`). Eso es correcto para
seguridad, pero choca con Terraform AWS 5.x:

| Capa | Qué ocurre |
|------|------------|
| **Tu código** | Correcto: bucket, versionado y tags. |
| **Rol del lab** | Puede crear/borrar buckets `curso-<usuario>-*` (operaciones de escritura). |
| **Provider AWS 5.x** | Tras crear o refrescar, llama lecturas como `s3:GetBucketWebsite` aunque no uses web. |
| **Límite del curso** | Esas lecturas **no están en el rol** y **no las podemos añadir** desde el curso. |
| **Consecuencia** | `plan`/`validate` sí; `apply`/`destroy` no son fiables para el alumno. |

**No es un error del alumno** si el mensaje muestra `assumed-role/lab-role-curso/...` y aun así
falla en `GetBucketWebsite`: el rol está bien asumido; falta un permiso que Terraform pide y que
nosotros no administramos.

El tester (`./scripts/check-aws-permissions.sh`) comprueba lo que el rol sí tiene. Si falla
`s3:GetBucketWebsite`, confirma que **no debes usar apply** en ese entorno.

## Comprueba tu entendimiento

**Composición correcta**
Ejecuta `terraform plan`.
→ El nombre del bucket incluye el prefijo `curso-<usuario>-` y lleva las etiquetas comunes.

**Versionado parametrizable**
Cambia `versioning = false` al consumir el módulo y vuelve a `plan`.
→ El recurso de versionado pasa a `Suspended`.

## Reto

### 1 — Cifrado por defecto

¿Cómo añadirías cifrado en reposo al módulo sin obligar a cada consumidor a configurarlo?

<details>
<summary>Ver solución</summary>

Añade dentro del módulo un `aws_s3_bucket_server_side_encryption_configuration` con SSE-S3
(`AES256`) por defecto, opcionalmente controlado por una variable `encryption` (default `true`). El
consumidor obtiene cifrado sin conocer los detalles.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `AccessDenied` en `s3:CreateBucket` como `user/alumno-...` | Terraform no asumió el rol (solo el usuario IAM) | `profile = "lab"` en el provider + `source scripts/load-env.sh`; `./scripts/check-aws-identity.sh` |
| `Reference to undeclared input variable "lab_user"` | Usas `var.lab_user` en el bucket pero no la declaraste | Paso 2: añádela en `variables.tf` y en `terraform.tfvars` (mismo valor que `AWS_LAB_USER`) |
| `403 AccessDenied` al crear o borrar el bucket | `lab_user` no coincide con `AWS_LAB_USER` del rol | Alinea ambos valores (p. ej. `david.pestana`) |
| `403 AccessDenied` en `s3:GetBucketWebsite` con `assumed-role/...` | Límite del entorno: Terraform 5.x pide lecturas que el rol no tiene y no podemos añadir | **No uses apply**; basta `terraform plan`. Limpia bucket/estado si probaste apply |
| `BucketAlreadyExists` | Los nombres de bucket son globales en AWS | Añade sufijo único (región, cuenta o `random_id`) |
| `Unsupported argument` | Input no declarado en el módulo | Revisa las `variable` del módulo |
| El bucket queda tras probar apply | Apply no está soportado en el entorno alumno | Borra con `aws --profile lab s3 rb s3://... --force` y `terraform state rm ...` |
| Acceso AWS falla | Fuera de la ventana o prefijo incorrecto | Reintenta en sesión; buckets `curso-<usuario>-*` en `us-east-2` |
