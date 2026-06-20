# M03-01 — Flujo de Pull Request

[← Página anterior](README.md) · [Siguiente página →](../M04-modulos-reutilizables/README.md)

> Práctica del módulo. La teoría y la demo están en el [README del módulo](README.md).

### Objetivo

Llevar un cambio (añadir una etiqueta común) desde una rama hasta `main` mediante un PR, pasando
por un conflicto y su resolución. Es trabajo de Git: no consume AWS.

### Prerrequisitos

- Tu fork y el dev container (M01). La estructura `environments/dev` de M02.

### En qué consiste

Creas una rama, modificas el código de `environments/dev`, abres un PR con la CLI de GitHub,
provocas y resuelves un conflicto, y mezclas.

### 1 — Crea una rama para tu cambio

**Acción:**

```bash
git switch -c feature/etiqueta-owner
```

**Por qué:** Aíslas tu cambio; `main` se mantiene estable mientras trabajas.
**Resultado esperado:** Estás en la rama `feature/etiqueta-owner` (`git status` lo confirma).

### 2 — Haz el cambio en el código

**Acción:** En `environments/dev/main.tf`, añade una etiqueta dentro de `locals`:

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = "equipo-dev"
  }
}
```

**Por qué:** Es un cambio pequeño y revisable, típico de un PR real.
**Resultado esperado:** `terraform fmt` no se queja y el archivo queda con el bloque `common_tags`.

### 3 — Commitea y publica la rama

**Acción:**

```bash
git add environments/dev/main.tf
git commit -m "feat(dev): añade common_tags con Owner"
git push -u origin feature/etiqueta-owner
```

**Por qué:** Subes la rama para poder abrir el PR.
**Resultado esperado:** La rama existe en tu fork en GitHub.

### 4 — Abre el Pull Request

**Acción:**

```bash
gh pr create --base main --head feature/etiqueta-owner \
  --title "Añade common_tags en dev" \
  --body "Etiquetas comunes para el entorno dev."
```

**Por qué:** El PR es el punto de revisión antes de tocar `main`.
**Resultado esperado:** `gh` devuelve la URL del PR.

> [!TIP]
> En un equipo, aquí otra persona revisaría el `plan`. En el curso puedes auto-revisarte: lee el
> diff con `gh pr diff` antes de mezclar.

### 5 — Provoca un conflicto (trabajo concurrente)

**Acción:** Simula que `main` cambió la misma línea mientras trabajabas:

```bash
git switch main
# edita environments/dev/main.tf y cambia Owner = "plataforma" en common_tags
git commit -am "feat(dev): Owner = plataforma"
git switch feature/etiqueta-owner
git merge main
```

**Por qué:** Reproduces el conflicto típico: dos ramas tocan la misma línea.
**Resultado esperado:** Git marca un conflicto en `main.tf` (`<<<<<<<`, `=======`, `>>>>>>>`).

### 6 — Resuelve el conflicto y completa el merge

**Acción:** Edita el archivo dejando el valor acordado (p. ej. `Owner = "plataforma"`), elimina los
marcadores y termina:

```bash
git add environments/dev/main.tf
git commit -m "merge: resuelve conflicto en common_tags"
git push
```

**Por qué:** El conflicto de **código** se resuelve editando y confirmando.
**Resultado esperado:** El PR queda sin conflictos y se puede mezclar (`gh pr merge --squash`).

## Comprueba tu entendimiento

**El PR existe**
Ejecuta `gh pr status`.
→ Aparece tu PR con la rama `feature/etiqueta-owner`.

**Conflicto resuelto**
Tras resolverlo, ejecuta `git status`.
→ No quedan archivos *unmerged* ni marcadores `<<<<<<<` en `main.tf`.

## Reto

### 1 — ¿Por qué no se mezcla el estado?

Si dos compañeros hacen `apply` a la vez con estado local, ¿qué problema aparece y cómo lo
resolverías?

<details>
<summary>Ver solución</summary>

Cada uno tendría su propio `.tfstate` y pisarían la realidad mutuamente (o lo corromperían). La
solución no es Git: es **estado remoto con bloqueo** (Terraform Cloud, M08), que impide que dos
`apply` corran a la vez sobre el mismo estado.

</details>

## Errores frecuentes

| Síntoma | Causa probable | Cómo arreglarlo |
|---------|----------------|-----------------|
| `gh: command not found` | No estás en el dev container o falta auth | Usa el dev container; `gh auth login` si hiciera falta |
| El push pide credenciales | El remoto no es tu fork | Comprueba `git remote -v`; debe apuntar a `tu-usuario/...` |
| El conflicto reaparece tras commitear | Quedaron marcadores `<<<<<<<` | Edita, elimina los marcadores y vuelve a `git add` |
| Mezclaste sin revisar el `plan` | Falta el paso de revisión | Usa `gh pr diff` y revisa el `plan` antes del merge |
