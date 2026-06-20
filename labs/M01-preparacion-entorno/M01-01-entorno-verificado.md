# M01-01 — Entorno verificado

[← Página anterior](README.md) · [Siguiente página →](../M02-organizacion-proyectos/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Dejar el dev container abierto, con credenciales activas y el **tester de permisos en verde**.

### Prerrequisitos

- Cuenta de GitHub y acceso al repositorio base del curso.
- Credenciales de AWS del curso (las facilita el formador), dentro de la ventana de acceso.

### En qué consiste

Forkeas, abres el entorno, eliges una vía de credenciales, verificas identidad y herramientas, y
lanzas el tester de permisos del curso.

### 1 — Haz un fork del repositorio base

**Acción:** En el repositorio base, pulsa **Fork** y confirma con **Create fork**.
**Por qué:** Necesitas tu propia copia para trabajar sin afectar al original.
**Resultado esperado:** La URL es `github.com/tu-usuario/terraform-avanzado-301`.

### 2 — Abre el dev container

**Acción:**
- En **Codespaces**: **Code → Codespaces → Create codespace on main**.
- En **local**: clona tu fork, ábrelo en VS Code y elige **Reopen in Container** (requiere Docker).

**Por qué:** Es tu entorno del curso, con todo el tooling ya instalado.
**Resultado esperado:** Se abre VS Code con una terminal; al final ves la salida de bienvenida del setup.

### 3 — Inyecta tus credenciales (elige una vía)

**Acción:** Según dónde trabajes:
- **Codespaces:** crea los *secrets* `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
  (y `AWS_SESSION_TOKEN` si son temporales) y `AWS_REGION`. Reabre el Codespace.
- **Local:** `cp .env.example .env`, edita tus claves y ejecuta `direnv allow`.

**Por qué:** El entorno trae los binarios, pero las credenciales son tuyas y deben quedar fuera del repo.
**Resultado esperado:** Las variables de AWS están disponibles en la terminal.

> [!TIP]
> En Codespaces, los *secrets* solo se cargan al **(re)crear** el Codespace. Si los añadiste
> después, reábrelo (Command Palette → *Rebuild Container*).

### 4 — Verifica identidad y herramientas

**Acción:**

```bash
aws sts get-caller-identity
terraform version
ansible --version
tflint --version
```

**Por qué:** Confirmas con qué identidad operas y que el tooling responde.
**Resultado esperado:** `get-caller-identity` devuelve tu `Account` y `Arn`; el resto imprime versiones.

> [!IMPORTANT]
> Si `get-caller-identity` falla fuera del horario de clase, es lo esperado (ventana AWS). Reinténtalo en sesión.

### 5 — Comprueba los permisos con el tester del curso

**Acción:**

```bash
./scripts/check-aws-permissions.sh
```

**Por qué:** Confirmas que tu cuenta puede hacer **todo** lo que pedirán los labs (S3, IAM/STS,
EC2/VPC) sin riesgo: los recursos de prueba se crean y se borran, y el lanzamiento de EC2 se valida
con `--dry-run` (no arranca nada).
**Resultado esperado:** Un resumen con `FAIL=0`. Si hay algún `FAIL`, compártelo con el formador.

### 6 — Inicia sesión en Terraform Cloud

**Acción:** `terraform login` y pega el token cuando se te pida.
**Por qué:** A partir de M08 guardarás el estado en Terraform Cloud; deja el acceso listo ya.
**Resultado esperado:** `Success! Terraform has obtained and saved an API token`.

## Comprueba tu entendimiento

**Identidad en AWS**
Ejecuta `aws sts get-caller-identity`.
→ Devuelve un JSON con tu `Account` y tu `Arn`.

**Permisos suficientes**
Ejecuta `./scripts/check-aws-permissions.sh`.
→ El resumen final muestra `FAIL=0`.

**Tooling disponible**
Ejecuta `terraform version` y `ansible --version`.
→ Ambos imprimen su versión sin errores.

## Reto

### 1 — ¿Qué vía de credenciales usarías en un pipeline?

Para tu portátil vale un `.env`; para Codespaces, los *secrets*. Pero, ¿qué usarías en un pipeline
de CI/CD para no dejar claves estáticas en ningún sitio?

<details>
<summary>Ver solución</summary>

**OIDC**: el pipeline asume un rol de AWS con un token efímero, sin almacenar claves. Lo montarás en
**M11**. Las claves estáticas son la última opción.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `get-caller-identity` falla con error de credenciales | Fuera de la ventana AWS, o no cargaste credenciales | Verifica la hora; revisa *secrets*/`.env` y reabre el entorno |
| Las variables del `.env` no aparecen | No ejecutaste `direnv allow` | Lánzalo en la raíz del repo y reentra en la carpeta |
| Los *secrets* de Codespaces no se cargan | Los añadiste con el Codespace ya abierto | *Rebuild Container* o recrea el Codespace |
| `No region` / endpoint error | Falta `AWS_REGION` | Defínela (en *secrets* o en `.env`), p. ej. `eu-west-1` |
| `Reopen in Container` no aparece (local) | Docker no está corriendo o falta la extensión Dev Containers | Arranca Docker e instala la extensión *Dev Containers* |
| El tester muestra `FAIL` | La cuenta no tiene ese permiso | Copia el `FAIL` y pásalo al formador / área de sistemas |
