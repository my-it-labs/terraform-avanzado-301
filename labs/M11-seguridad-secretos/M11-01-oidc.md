# M11-01 — OIDC GitHub ↔ AWS

[← Página anterior](README.md) · [Siguiente página →](M11-02-minimo-privilegio.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Configurar OIDC para que GitHub Actions asuma un rol de AWS **sin** claves estáticas, y migrar el
workflow de M10 a este método.

### Prerrequisitos

- El pipeline de M10 funcionando y credenciales activas (ventana AWS) para crear IAM.

### En qué consiste

Creas el proveedor OIDC, un rol con trust policy hacia tu repo, y cambias el workflow para asumirlo.

### 1 — Da de alta el proveedor OIDC de GitHub

**Acción:** Define en Terraform (o consola) el proveedor OIDC de GitHub:

```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
```

**Por qué:** AWS necesita confiar en el emisor de tokens de GitHub.
**Resultado esperado:** El proveedor OIDC existe en IAM.

### 2 — Crea el rol con trust policy hacia tu repo

**Acción:**

```hcl
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:TU-ORG/terraform-avanzado-301:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "ci" {
  name               = "tfadv-ci"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}
```

**Por qué:** Solo tu repo (y rama `main`) podrá asumir el rol.
**Resultado esperado:** Existe el rol `tfadv-ci` con su trust policy.

### 3 — Cambia el workflow para asumir el rol

**Acción:** En el workflow de apply, sustituye las claves por OIDC:

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  apply:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::<ACCOUNT_ID>:role/tfadv-ci
          aws-region: eu-west-1
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform apply -auto-approve
```

**Por qué:** El job obtiene credenciales temporales asumiendo el rol; ya no hay claves en Secrets.
**Resultado esperado:** El workflow ya no usa `AWS_ACCESS_KEY_ID`.

### 4 — Verifica que el pipeline funciona sin claves

**Acción:** Borra los secretos `AWS_ACCESS_KEY_ID`/`SECRET` del repo y dispara el workflow.
**Por qué:** Confirmas que ya no dependes de claves estáticas.
**Resultado esperado:** El `apply` corre asumiendo el rol; en los logs ves `Assuming role`.

> [!WARNING]
> Crea IAM real. Hazlo en la ventana y limpia los roles de prueba al terminar.

## Comprueba tu entendimiento

**Sin claves estáticas**
Revisa los Secrets del repo.
→ Ya no hay `AWS_ACCESS_KEY_ID`; el pipeline sigue funcionando.

**Confianza acotada**
Mira la trust policy del rol.
→ Solo confía en tu `repo:...:ref:refs/heads/main`.

## Reto

### 1 — Restringir por entorno

¿Cómo permitirías asumir el rol solo desde el environment `production` y no desde cualquier rama?

<details>
<summary>Ver solución</summary>

En la condición del `sub` usa `repo:TU-ORG/REPO:environment:production` en lugar de
`ref:refs/heads/main`. Así el token solo es válido cuando el job corre en ese environment protegido.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `Not authorized to perform sts:AssumeRoleWithWebIdentity` | Trust policy no casa con tu `sub` | Revisa org/repo/ref exactos en la condición |
| `Credentials could not be loaded` | Falta `permissions: id-token: write` | Añádelo al workflow |
| El thumbprint es rechazado | Cambió el del emisor | Usa el data source de OIDC o el thumbprint vigente |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
