#!/usr/bin/env sh

set -eu

: "${CERTS_DIR:=./certs}"
: "${VAULT_ADDR:=http://127.0.0.1:8200}"
: "${VAULT_TOKEN:=root}"

#
# ROOT

vault secrets enable pki

vault secrets tune -max-lease-ttl=87600h pki

vault write -field=certificate pki/root/generate/internal \
    common_name="example.com" \
    issuer_name="root-2022" \
    ttl=87600h >"$CERTS_DIR/root_2022_ca.crt"

vault write pki/roles/2022-servers allow_any_name=true

vault write pki/config/urls \
    issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
    crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

#
# INTERMEDIATE

vault secrets enable -path=pki_int pki

vault secrets tune -max-lease-ttl=43800h pki_int

vault write -format=json pki_int/intermediate/generate/internal \
    common_name="example.com Intermediate Authority" \
    issuer_name="example-dot-com-intermediate" |
    bin/jq -r '.data.csr' >"$CERTS_DIR/pki_intermediate.csr"

vault write -format=json pki/root/sign-intermediate \
    issuer_ref="root-2022" \
    csr=@"$CERTS_DIR/pki_intermediate.csr" \
    format=pem_bundle ttl="43800h" |
    bin/jq -r '.data.certificate' >"$CERTS_DIR/intermediate.cert.pem"

vault write pki_int/intermediate/set-signed certificate=@"$CERTS_DIR/intermediate.cert.pem"

vault write pki_int/roles/example-dot-com \
    issuer_ref="$(vault read -field=default pki_int/config/issuers)" \
    allowed_domains="example.com" \
    allow_subdomains=true \
    max_ttl="720h"

#
# CRL

vault read -field certificate pki_int/cert/crl >"$CERTS_DIR/intermediate.crl.pem"
echo "" >>"$CERTS_DIR/intermediate.crl.pem"
