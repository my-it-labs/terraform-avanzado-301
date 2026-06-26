#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# check-aws-identity.sh — ¿Estás con el usuario IAM o con el rol del lab asumido?
#
# Uso:   ./scripts/check-aws-identity.sh
#
# Muchos alumnos tienen el .env bien pero ejecutan aws/terraform SIN perfil lab.
# Este script lo deja claro en segundos.
# ------------------------------------------------------------------------------
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GREEN='\033[32m'; RED='\033[31m'; YEL='\033[33m'; BOLD='\033[1m'; NC='\033[0m'

if [ -f "$ROOT/.env" ] && [ -z "${AWS_ACCESS_KEY_ID:-}" ]; then
  set -a
  # shellcheck source=/dev/null
  source "$ROOT/.env"
  set +a
fi

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-2}}"
export AWS_REGION="$REGION" AWS_DEFAULT_REGION="$REGION"

printf "${BOLD}== Comprobación de identidad AWS (rol del lab) ==${NC}\n\n"

# --- Variables mínimas --------------------------------------------------------
missing=0
for v in AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; do
  if [ -z "${!v:-}" ]; then
    printf "  ${RED}x${NC} Falta ${v}\n"
    missing=1
  else
    printf "  ${GREEN}✔${NC} ${v} definida\n"
  fi
done

if [ -n "${AWS_ROLE_ARN:-}" ]; then
  printf "  ${GREEN}✔${NC} AWS_ROLE_ARN=${AWS_ROLE_ARN}\n"
else
  printf "  ${RED}x${NC} Falta AWS_ROLE_ARN en .env\n"
  missing=1
fi

if [ -n "${AWS_LAB_USER:-}" ]; then
  printf "  ${GREEN}✔${NC} AWS_LAB_USER=${AWS_LAB_USER}\n"
else
  printf "  ${YEL}!${NC} AWS_LAB_USER no definido (prefijos curso-*)\n"
fi

if [ "$missing" -eq 1 ]; then
  echo
  echo "Carga credenciales:  source scripts/load-env.sh"
  exit 1
fi

# --- Perfil lab ----------------------------------------------------------------
mkdir -p "$HOME/.aws"
{
  echo "[profile lab]"
  echo "role_arn = ${AWS_ROLE_ARN}"
  echo "credential_source = Environment"
  echo "region = ${REGION}"
  echo "role_session_name = ${AWS_ROLE_SESSION_NAME:-tf-curso}"
} > "$HOME/.aws/config"

printf "\n${BOLD}1) Sin perfil (lo que usa Terraform si no haces nada más)${NC}\n"
if ID_DEFAULT="$(aws sts get-caller-identity 2>/tmp/_e1)"; then
  ARN_DEFAULT="$(echo "$ID_DEFAULT" | jq -r '.Arn')"
  printf "   Arn: %s\n" "$ARN_DEFAULT"
  if echo "$ARN_DEFAULT" | grep -q ':user/'; then
    printf "   ${YEL}! Usuario IAM base — NO es el rol del lab${NC}\n"
  elif echo "$ARN_DEFAULT" | grep -q 'assumed-role/'; then
    printf "   ${GREEN}✔ Rol asumido${NC}\n"
  fi
else
  printf "   ${RED}x Error:${NC} %s\n" "$(head -n1 /tmp/_e1)"
fi

printf "\n${BOLD}2) Con perfil lab (lo correcto para el curso)${NC}\n"
if ID_LAB="$(aws --profile lab sts get-caller-identity 2>/tmp/_e2)"; then
  ARN_LAB="$(echo "$ID_LAB" | jq -r '.Arn')"
  printf "   Arn: %s\n" "$ARN_LAB"
  if echo "$ARN_LAB" | grep -q 'assumed-role/'; then
    printf "   ${GREEN}✔ PASS — rol del lab asumido${NC}\n"
    LAB_OK=1
  else
    printf "   ${RED}x FAIL — no es assumed-role${NC}\n"
    LAB_OK=0
  fi
else
  printf "   ${RED}x Error al asumir rol:${NC} %s\n" "$(head -n1 /tmp/_e2)"
  LAB_OK=0
fi

printf "\n${BOLD}== Resultado ==${NC}\n"
if [ "${LAB_OK:-0}" -eq 1 ]; then
  printf "${GREEN}El rol funciona con --profile lab.${NC}\n"
  echo
  echo "Para Terraform en esta terminal:"
  echo "  export AWS_PROFILE=lab"
  echo "  cd environments/dev && terraform apply -auto-approve -refresh=false"
  echo
  echo "O inyecta credenciales STS del rol en el entorno (terraform sin profile):"
  echo "  source scripts/assume-lab-role.sh"
  exit 0
fi

printf "${RED}No se pudo asumir el rol del lab.${NC}\n"
echo
echo "Prueba manualmente:"
echo "  source scripts/load-env.sh"
echo "  aws --profile lab sts get-caller-identity"
echo
echo "Assume-role explícito (diagnóstico):"
echo "  aws sts assume-role \\"
echo "    --role-arn \"${AWS_ROLE_ARN}\" \\"
echo "    --role-session-name ${AWS_ROLE_SESSION_NAME:-tf-curso}"
exit 1
