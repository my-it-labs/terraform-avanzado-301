# M07-02 — Laboratorio: análisis de drift

Material para **M07-02**. **Consume AWS** (🟡): crea un bucket S3 real con `terraform apply`.
Acuérdate de `terraform destroy` al terminar.

## Estructura

```
labs-sandbox/m07-drift/
├── README.md           ← Estás aquí
├── main.tf             ← bucket con etiqueta Owner gestionada
├── variables.tf        ← aws_region, lab_user
└── terraform.tfvars    ← valores de ejemplo
```

> [!TIP]
> Cambia `lab_user` en `terraform.tfvars` por tu usuario (p. ej. `david.pestana`). El bucket debe
> empezar por `curso-<lab_user>-`.

## Comandos (M07-02)

```bash
cd labs-sandbox/m07-drift
terraform init
terraform apply

# Provoca drift FUERA de Terraform (Opción B — AWS CLI):
aws s3api put-bucket-tagging \
  --bucket curso-alumno-drift-demo \
  --tagging 'TagSet=[{Key=Owner,Value=manual}]'

# Detecta el drift
terraform plan              # propone revertir Owner a "terraform"
terraform plan -refresh-only  # solo muestra el drift, sin proponer cambios de código

# Limpieza
terraform destroy
```

> [!NOTE]
> `put-bucket-tagging` **reemplaza** todas las etiquetas del bucket. Aquí solo se gestiona `Owner`,
> así que el comando es suficiente. Si tu rol de laboratorio no tiene `s3:PutBucketTagging`,
> consulta con el formador o provoca el drift sobre otro atributo permitido.
