# M11-02 — Mínimo privilegio

[← Página anterior](M11-01-oidc.md) · [Siguiente página →](../M12-troubleshooting/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Ajustar la **permission policy** del rol de CI al mínimo necesario, partiendo de poco y ampliando
solo cuando un `apply` lo exija.

### Prerrequisitos

- El rol `tfadv-ci` con OIDC (M11-01).

### En qué consiste

Adjuntas una política mínima al rol, ejecutas el pipeline, observas qué permiso falta y lo añades.

### 1 — Empieza con una política mínima

**Acción:** Adjunta al rol una política con solo lo justo para el bucket del entorno:

```hcl
data "aws_iam_policy_document" "ci" {
  statement {
    sid     = "S3Manage"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:PutBucketTagging",
      "s3:GetBucketTagging",
      "s3:PutBucketVersioning",
      "s3:GetBucketVersioning",
    ]
    resources = ["arn:aws:s3:::tfadv-*"]
  }
}

resource "aws_iam_role_policy" "ci" {
  role   = aws_iam_role.ci.id
  policy = data.aws_iam_policy_document.ci.json
}
```

**Por qué:** Mínimo privilegio: solo lo necesario, y acotado a recursos `tfadv-*`.
**Resultado esperado:** El rol puede gestionar buckets del proyecto y nada más.

### 2 — Ejecuta el pipeline y observa el fallo

**Acción:** Dispara el workflow (M11-01) y mira los logs.
**Por qué:** Si falta un permiso, el `apply` falla con un `AccessDenied` que **nombra la acción**.
**Resultado esperado:** Ves algo como `... is not authorized to perform: s3:GetBucketLocation`.

### 3 — Añade solo el permiso que falta

**Acción:** Agrega esa acción concreta a la lista de la política (p. ej.
`s3:GetBucketLocation`), aplica el cambio del rol y reintenta.
**Por qué:** Amplías de forma quirúrgica, no con comodines.
**Resultado esperado:** El `apply` avanza; repite hasta que pase entero.

> [!TIP]
> El error de `AccessDenied` te dice exactamente qué acción y, a veces, qué recurso. Es tu lista de
> la compra: añade eso, nada más.

### 4 — Verifica que no hay comodines de más

**Acción:** Revisa la política final.
**Por qué:** Confirmas que no quedó ningún `"*"` innecesario.
**Resultado esperado:** Solo acciones concretas sobre `arn:aws:s3:::tfadv-*`.

> [!WARNING]
> Limpia los roles/políticas de prueba al terminar la sesión.

## Comprueba tu entendimiento

**Mínimo funcional**
Ejecuta el pipeline tras ajustar.
→ El `apply` pasa con una política sin comodines amplios.

**El error guía**
Revisa un log de `AccessDenied`.
→ Identificas la acción exacta que faltaba.

## Reto

### 1 — Permisos efímeros más estrictos

¿Cómo limitarías aún más el alcance temporal de las credenciales que entrega el rol?

<details>
<summary>Ver solución</summary>

Reduce la `max_session_duration` del rol al mínimo razonable (p. ej. 1 hora) y acota la trust policy
a un environment concreto. Menos tiempo de vida y menos quién = menor superficie si algo se filtra.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `AccessDenied` en `apply` | Falta un permiso | Añade la acción que nombra el error |
| El pipeline funciona pero con `*` | Política demasiado amplia | Recorta a acciones y recursos concretos |
| `MalformedPolicyDocument` | JSON de política inválido | Genera con `aws_iam_policy_document` y revisa |
| Acceso AWS falla | Fuera de la ventana | Reintenta en sesión |
