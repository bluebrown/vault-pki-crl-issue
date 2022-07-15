#!/usr/bin/env sh

set -eu

: "${CERTS_DIR:=./certs}"
: "${SERVER_CM:=localhost}"

openssl req \
    -x509 \
    -newkey rsa:4096 \
    -sha256 \
    -days 3650 \
    -nodes \
    -keyout "$CERTS_DIR/server.key" \
    -out "$CERTS_DIR/server.crt" \
    -subj "/CN=$SERVER_CM" \
    -addext "subjectAltName=DNS:$SERVER_CM"
