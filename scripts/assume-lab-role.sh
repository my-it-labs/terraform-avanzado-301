#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# assume-lab-role.sh — exporta credenciales TEMPORALES del rol lab en esta shell
#
# Uso (obligatorio con source):
#   source scripts/assume-lab-role.sh
#
# Después, aws y terraform usan el rol SIN necesitar AWS_PROFILE=lab.
# Verifica con:  aws sts get-caller-identity  →  assumed-role/lab-role-curso/...
# ------------------------------------------------------------------------------

_assume_lab_role() {
  local root
  root="$(cd "$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")/.." && pwd)"

  # shellcheck source=/dev/null
  source "$root/scripts/load-env.sh" || return 1

  if [ -z "${AWS_ROLE_ARN:-}" ]; then
    echo "ERROR: falta AWS_ROLE_ARN en .env"
    return 1
  fi

  export AWS_PROFILE=lab

  if ! eval "$(aws configure export-credentials --profile lab --format env 2>/tmp/_assume_err)"; then
    echo "ERROR: no se pudo exportar credenciales del rol lab:"
    sed 's/^/  /' /tmp/_assume_err
    echo
    echo "Diagnóstico:  ./scripts/check-aws-identity.sh"
    return 1
  fi

  unset AWS_PROFILE

  echo "OK: credenciales del rol lab en esta shell."
  aws sts get-caller-identity
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Ejecuta con:  source scripts/assume-lab-role.sh"
  exit 1
fi

_assume_lab_role
