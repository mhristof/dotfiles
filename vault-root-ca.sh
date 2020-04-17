#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

MOUNT="${1:-rootca}"
DOMAIN="${2:-example.com}"


die() { echo "$*" 1>&2 ; exit 1; }
function usage {
    cat << EOF
Setup a root ca and an intermediate mount in vault to issue certificates.

Usage:
    $(basename "$0") [-m mount_path] [-d domain]

Args:
    -h              Prints this help message
    -m path         Vault mount path for the PKI
    -d domain.com   Domain name for the certificate
EOF
    exit 1
}

# https://stackoverflow.com/a/30026641/2599522
for arg in "$@"; do
  shift
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    *)        set -- "$@" "$arg"
  esac
done

while getopts "d:m:hv" OPTION
do
     case $OPTION in
         d) DOMAIN=$OPTARG;;
         m) MOUNT=$OPTARG;;
         h)
             usage
             ;;
         ?)
             usage
             ;;
     esac
done

if [[ -z $VAULT_ADDR ]]; then
    die "Error, VAULT_ADDR is not set"
fi

if [[ -z $VAULT_TOKEN ]] && ! vault secrets list &> /dev/null; then
    die "Error, VAULT_TOKEN is not set"
fi

vault secrets disable "${MOUNT}"
vault secrets disable "${MOUNT}_int"
vault secrets enable -path "${MOUNT}" pki
vault secrets tune -max-lease-ttl=8760h "${MOUNT}"
vault write "${MOUNT}/root/generate/internal" common_name="$DOMAIN" ttl=8760h

vault write "${MOUNT}/roles/${DOMAIN}" allowed_domains="$DOMAIN" allow_subdomains=true max_ttl=72h

vault secrets enable -path="${MOUNT}_int" pki
vault write -format json "${MOUNT}_int/intermediate/generate/internal" common_name="$DOMAIN Intermediate Authority" ttl=43800h | jq .data.csr -r > "${MOUNT}_int".csr
vault write -format json "${MOUNT}/root/sign-intermediate" csr=@"${MOUNT}_int.csr" format=pem_bundle ttl=43800h | jq .data.certificate -r > signed_certificate.pem
vault write "${MOUNT}_int/intermediate/set-signed" certificate=@signed_certificate.pem

exit 0
