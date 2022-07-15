#!/usr/bin/env sh

set -eu

: "${CLIENT_DIR:=./client}"
: "${VAULT_ADDR:=http://127.0.0.1:8200}"
: "${VAULT_TOKEN:=root}"

export VAULT_ADDR
export VAULT_TOKEN

vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="24h" | bin/jq -r '.data' >"$CLIENT_DIR/client.json"
bin/jq -r '.certificate' "$CLIENT_DIR/client.json" >"$CLIENT_DIR/client.crt"
bin/jq -r '.private_key' "$CLIENT_DIR/client.json" >"$CLIENT_DIR/client.key"
