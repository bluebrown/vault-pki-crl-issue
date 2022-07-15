#!/usr/bin/env sh

set -eu

curl -fsSL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 >bin/jq
chmod +x bin/jq
