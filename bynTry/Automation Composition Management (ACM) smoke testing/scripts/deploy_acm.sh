#!/usr/bin/env bash
set -euo pipefail

echo "Starting ACM deployment..."

# --------------------------------------------------
# Validate required environment variables
# --------------------------------------------------
: "${ONAP_HOST:?ONAP_HOST not set}"
: "${ONAP_USER:?ONAP_USER not set}"
: "${ONAP_PASSWORD:?ONAP_PASSWORD not set}"
: "${INSTANCE_ID:?INSTANCE_ID not set}"

MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-300}"
SLEEP_INTERVAL=5

AUTH="-u ${ONAP_USER}:${ONAP_PASSWORD}"
BASE_URL="${ONAP_HOST}/onap/automationcomposition/v1"

# --------------------------------------------------
# Trigger DEPLOY
# --------------------------------------------------
echo "Triggering DEPLOY for instance: ${INSTANCE_ID}"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  ${AUTH} \
  -X POST \
  "${BASE_URL}/instances/${INSTANCE_ID}/deploy")

if [[ "$HTTP_CODE" != "200" && "$HTTP_CODE" != "202" ]]; then
  echo "Failed to trigger deploy. HTTP status: $HTTP_CODE"
  exit 1
fi

echo "Deploy request accepted."

# --------------------------------------------------
# Wait for DEPLOYED state
# --------------------------------------------------
echo "Waiting for DEPLOYED state..."

ELAPSED=0

while [[ $ELAPSED -lt $MAX_WAIT_SECONDS ]]; do

  RESPONSE=$(curl -s \
    ${AUTH} \
    "${BASE_URL}/instances/${INSTANCE_ID}")

  STATE=$(echo "$RESPONSE" | jq -r '.state')

  echo "Current state: $STATE"

  if [[ "$STATE" == "DEPLOYED" || "$STATE" == "RUNNING" ]]; then
    echo "Instance successfully deployed."
    exit 0
  fi

  if [[ "$STATE" == "ERROR" ]]; then
    echo "Instance entered ERROR state."
    echo "$RESPONSE"
    exit 1
  fi

  sleep $SLEEP_INTERVAL
  ELAPSED=$((ELAPSED + SLEEP_INTERVAL))

done

echo "Timeout waiting for DEPLOYED state."
exit 1
