# M08-01 — Migración a Terraform Cloud

[← Página anterior](README.md) · [Siguiente página →](../M09-importacion-refactorizacion/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Migrar el estado local de un entorno a un workspace de Terraform Cloud y aplicar desde ahí.

### Prerrequisitos

- `terraform login` hecho (M01) y una organización en Terraform Cloud.
- Credenciales de AWS activas (ventana).

### En qué consiste

Configuras el backend `cloud`, migras el estado, das credenciales al workspace y aplicas.

### 1 — Añade el bloque cloud

**Acción:** En `environments/dev/main.tf`, dentro de `terraform { ... }`:

```hcl
terraform {
  cloud {
    organization = "TU-ORG"
    workspaces {
      name = "tfadv-dev"
    }
  }
}
```

**Por qué:** Declaras que el estado vivirá en TFC, en el workspace `tfadv-dev`.
**Resultado esperado:** El bloque `cloud` apunta a tu organización.

### 2 — Migra el estado

**Acción:**

```bash
cd environments/dev
terraform init
```

**Por qué:** `init` detecta el cambio de backend y ofrece migrar el estado local a TFC.
**Resultado esperado:** Te pregunta si migrar (`yes`); el workspace `tfadv-dev` aparece en la UI con el estado.

> [!IMPORTANT]
> Responde `yes` solo si quieres subir tu estado local. A partir de aquí, el estado de verdad vive
> en TFC.

### 3 — Da credenciales de AWS al workspace

**Acción:** En la UI de TFC → workspace `tfadv-dev` → **Variables**, añade como *Environment
variables* (marcadas **sensitive**):
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- (`AWS_SESSION_TOKEN` si son temporales) y `AWS_REGION`.

**Por qué:** Si ejecutas en TFC (remote), el `apply` corre allí y necesita credenciales propias.
**Resultado esperado:** El workspace tiene las variables de entorno necesarias.

### 4 — Aplica desde Terraform Cloud

**Acción:**

```bash
terraform plan
terraform apply
```

**Por qué:** Compruebas el flujo completo con estado remoto y locking.
**Resultado esperado:** El run aparece en la UI de TFC; el estado se actualiza allí.

### 5 — Comprueba el locking

**Acción:** Con un `apply` en curso, abre otra terminal y lanza `terraform plan` en el mismo
entorno.
**Por qué:** Verificas que TFC bloquea el estado mientras hay una operación.
**Resultado esperado:** El segundo comando informa de que el estado está bloqueado.

> [!WARNING]
> Si creaste recursos reales, `terraform destroy` al terminar.

## Comprueba tu entendimiento

**Estado en TFC**
Abre el workspace en la UI de Terraform Cloud.
→ Ves el estado y el historial de runs.

**Locking activo**
Lanza dos operaciones a la vez.
→ La segunda espera por el lock.

## Reto

### 1 — Un workspace por entorno

¿Cómo separarías dev y prod en TFC para que un `apply` en dev no pueda tocar el estado de prod?

<details>
<summary>Ver solución</summary>

Un **workspace por entorno** (`tfadv-dev`, `tfadv-prod`), cada uno con su `cloud { workspaces {
name = ... } }` y sus propias variables de credenciales. Estados aislados = no hay forma de
mezclarlos.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Error: Required token could not be found` | No hiciste `terraform login` | Lánzalo y pega el token |
| `No valid credential sources` en el run | Faltan variables de AWS en el workspace | Añádelas como *Environment variables* sensibles |
| `init` no ofrece migrar | Ya estaba en backend remoto | Revisa el bloque `cloud`; borra `.terraform` y reintenta |
| `Organization not found` | Nombre de organización incorrecto | Usa el slug exacto de tu org en TFC |
