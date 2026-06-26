# M05 — Laboratorio: versionado y distribución de módulos

Material de **demostración y práctica** para el módulo M05. No consume AWS: basta con
`terraform init` y, opcionalmente, `plan`.

## Estructura

```
labs-sandbox/m05/
├── README.md                 ← Estás aquí (guía formador/alumno)
├── publisher/                ← Repo simulado del *autor* del módulo
│   ├── README.md
│   ├── s3/main.tf            ← Módulo S3 v1.1.0 (comentado)
│   └── snippets/
│       └── main.v1.0.0.tf    ← Snapshot v1.0.0 para comparar en demo
└── consumer/                 ← Repo simulado del *consumidor*
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

## Flujo de demostración (formador)

### 1. Mostrar el contrato v1.0.0

Abre `publisher/snippets/main.v1.0.0.tf` y `publisher/s3/main.tf`. Señala:

- Misma interfaz base (`bucket_name`, `tags`, `versioning`).
- En **v1.1.0** aparece `force_destroy` (input **opcional** con default) → cambio **MINOR**.

### 2. Consumir en local (sin Git)

```bash
cd labs-sandbox/m05/consumer
terraform init
terraform validate
```

El `source = "../publisher/s3"` fija el código local; no hay tag todavía.

### 3. Publicar con tags (Git)

Desde la raíz del repo (o un repo dedicado de módulos):

```bash
# v1.0.0 — commit donde el módulo NO tenía force_destroy
git tag m05-s3-v1.0.0 <commit-v1.0.0>
git push origin m05-s3-v1.0.0

# v1.1.0 — commit actual del módulo (con force_destroy)
git tag m05-s3-v1.1.0
git push origin m05-s3-v1.1.0
```

> En un repo real de producto usarías `v1.0.0`, `v1.1.0`. Aquí el prefijo `m05-s3-` evita
> colisiones con otros tags del curso.

### 4. Consumir por referencia remota

En `consumer/main.tf`, comenta el `source` local y descomenta el bloque Git con `?ref=`:

```hcl
source = "git::https://github.com/my-it-labs/terraform-avanzado-301.git//labs-sandbox/m05/publisher/s3?ref=m05-s3-v1.0.0"
```

```bash
terraform init -upgrade
terraform plan
```

Cambia `ref` a `m05-s3-v1.1.0` y repite `init -upgrade` + `plan` para mostrar la actualización
**controlada**.

### 5. Mensajes clave para el aula

| Idea | Frase corta |
|------|-------------|
| Tag = foto congelada | Un tag Git no cambia aunque `main` siga evolucionando. |
| `?ref=` | El consumidor decide qué versión descargar. |
| Nunca `main` sin pin | Apuntar a `main` es pedir sorpresas en producción. |
| SemVer | Input opcional nuevo → **MINOR**; romper interfaz → **MAJOR**. |
| Caché | Si no ves la nueva versión → `terraform init -upgrade`. |

## Práctica del alumno

Sigue [M05-01](../../labs/M05-versionado-modulos/M05-01-versionado-distribucion.md) usando este
directorio como base o tu propio módulo S3 de M04.
