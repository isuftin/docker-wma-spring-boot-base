#!/bin/ash
# shellcheck shell=dash

serverPort=${serverPort:?}
serverContextPath=${serverContextPath:?}
curl -k "https://127.0.0.1:${serverPort}${serverContextPath}${HEALTH_CHECK_ENDPOINT}" | grep -q ${HEALTHY_RESPONSE_CONTAINS} || exit 1
