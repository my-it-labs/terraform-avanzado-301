# M07 — Laboratorio: operar el estado

Material para **M07-01** (`state list/show/mv`). **Consume AWS** (🟡): crea un bucket S3 real con
`terraform apply`. Acuérdate de `terraform destroy` al terminar.

> El drift (M07-02) está en el directorio hermano [`../m07-drift`](../m07-drift).

## Estructura

```
labs-sandbox/m07/
├── README.md                       ← Estás aquí
├── main.tf                         ← bucket mínimo para operar el estado
├── variables.tf                    ← aws_region, lab_user
├── terraform.tfvars                ← valores de ejemplo
└── snippets/
    └── step-rename-primary.tf      ← M07-01 paso 3 (recurso renombrado, referencia)
```

> [!TIP]
> Cambia `lab_user` en `terraform.tfvars` por tu usuario (p. ej. `david.pestana`). Los buckets
> deben empezar por `curso-<lab_user>-`.

## Comandos (M07-01)

```bash
cd labs-sandbox/m07
terraform init
terraform apply

# Inspecciona el estado
terraform state list
terraform state show aws_s3_bucket.data

# Renombra (usa el snippet step-rename-primary.tf) y reconcilia sin recrear
terraform state mv aws_s3_bucket.data aws_s3_bucket.primary
terraform plan        # -> No changes

# Limpieza
terraform destroy
```
