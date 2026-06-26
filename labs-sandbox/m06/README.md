# M06 — Laboratorio: expresiones avanzadas

Material de **demostración y práctica** para M06-01, M06-02 y M06-03. **No consume AWS:**
basta `terraform init -backend=false`, `validate` y `plan` (sin `apply`).

## Estructura

```
labs-sandbox/m06/
├── README.md           ← Estás aquí
├── main.tf             ← Código completo comentado (estado final tras M06-03)
├── variables.tf        ← Inputs del sandbox
├── terraform.tfvars    ← Valores de ejemplo
└── snippets/
    ├── step01-for-each-count.tf   ← Solo M06-01 (referencia)
    └── step02-locals-tags.tf      ← M06-01 + M06-02 (referencia)
```

## Cómo practicar

Sigue los labs en orden y **ve añadiendo** al `main.tf`, o parte del archivo completo y comenta
bloques que aún no hayas visto:

| Lab | Qué añades |
|-----|------------|
| [M06-01](../../labs/M06-expresiones-avanzadas/M06-01-count-for-each.md) | `for_each` sobre mapa de buckets + `count` condicional |
| [M06-02](../../labs/M06-expresiones-avanzadas/M06-02-locals-condicionales.md) | `locals` derivados, `merge`, `lookup`, versionado filtrado |
| [M06-03](../../labs/M06-expresiones-avanzadas/M06-03-hcl-avanzado.md) | `dynamic`, `try`, `lifecycle.precondition` |

## Comandos

```bash
cd labs-sandbox/m06
terraform fmt
terraform init -backend=false
terraform validate
terraform plan -refresh=false

# M06-01: recurso extra con count
terraform plan -refresh=false -var="create_inventory=true"
```

> `plan -refresh=false` evita llamadas AWS innecesarias; no hace falta `apply` en M06.

## Demo formador

1. **M06-01** — `plan` muestra `this["logs"]`, `this["data"]`, `this["tmp"]`; con
   `create_inventory=true` aparece `inventory[0]`.
2. **M06-02** — versionado solo en `data`; tags con `Role` y `Versioning`.
3. **M06-03** — lifecycle `expire` solo en buckets con `expire_days > 0`; cambiar prefijo rompe
   la `precondition` en plan.
