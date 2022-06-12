#!/bin/sh

export FLY_API_HOSTNAME="127.0.0.1:4280" # or set to `127.0.0.1:4280` when using 'flyctl proxy'
export FLY_API_TOKEN=$(fly auth token)

curl -i -X DELETE \
-H "Authorization: Bearer ${FLY_API_TOKEN}" -H "Content-Type: application/json" \
"http://${FLY_API_HOSTNAME}/v1/apps/rust-mq/machines/$1"
