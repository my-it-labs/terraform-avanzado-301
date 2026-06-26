# Publisher — autor del módulo S3

Simula el repositorio donde **publicas** el módulo. En producción sería un repo aparte
(p. ej. `terraform-modules`) con solo módulos reutilizables.

## Versiones de este lab

| Tag sugerido | Contenido | SemVer |
|--------------|-----------|--------|
| `m05-s3-v1.0.0` | Ver `snippets/main.v1.0.0.tf` | MAJOR 1 — primera versión estable |
| `m05-s3-v1.1.0` | Ver `s3/main.tf` (añade `force_destroy`) | MINOR 1 — compatible hacia atrás |

## Publicar

```bash
git tag m05-s3-v1.0.0 <commit-anterior-sin-force_destroy>
git push origin m05-s3-v1.0.0

git tag m05-s3-v1.1.0
git push origin m05-s3-v1.1.0
```

El consumidor elige cuándo pasar de `v1.0.0` a `v1.1.0` cambiando solo el `?ref=`.
