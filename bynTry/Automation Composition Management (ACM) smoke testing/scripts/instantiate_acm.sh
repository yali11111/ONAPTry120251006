#!/usr/bin/env bash
set -euo pipefail

echo "Starting ACM instance instantiation..."

# ----------------------------
# Validate environment variables
# ----------------------------
: "${ONAP_HOST:?ONAP_HOST not set}"
: "${ONAP_USER:?ONAP_USER not set}"
: "${ONAP_PASSWORD:?ONAP_PASSWORD not set}"
: "${COMPOSITION_ID:?COMPOSITION_ID not set}"

INSTANCE_NAME="${INSTANCE_NAME:-acm-instance-$(date +%s)}"
AUTH="-u ${ONAP_USER}:${ONAP_PASSWORD}"
BASE_URL="${ONAP_HOST}/onap/automationcomposition/v1"

# ----------------------------
# Step 1: Instantiate ACM instance
# ----------------------------
echo "Creating ACM instance: $INSTANCE_NAME from composition $COMPOSITION_ID"

INSTANCE_ID=$(curl -s \
  ${AUTH} \
  -X POST \
  -H "Content-Type: application/json" \
  -d "{\"compositionId\":\"$COMPOSITION_ID\",\"instanceName\":\"$INSTANCE_NAME\"}" \
  "${BASE_URL}/instances" \
  | jq -r '.instanceId')

if [[ -z "$INSTANCE_ID" || "$INSTANCE_ID" == "null" ]]; then
  echo "Failed to create ACM instance."
  exit 1
fi

echo "ACM instance created successfully."
echo "INSTANCE_ID=$INSTANCE_ID"
echo "$INSTANCE_ID" > instance_id.txt

# ----------------------------
# Step 2: Optional - Wait for VALIDATED state
# ----------------------------
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-120}"
SLEEP_INTERVAL=5
ELAPSED=0

echo "Waiting for instance to reach VALIDATED state..."

while [[ $ELAPSED -lt $MAX_WAIT_SECONDS ]]; do
  RESPONSE=$(curl -s ${AUTH} "${BASE_URL}/instances/${INSTANCE_ID}")
  STATE=$(echo "$RESPONSE" | jq -r '.state')

  echo "Current state: $STATE"

  if [[ "$STATE" == "VALIDATED" ]]; then
    echo "Instance validated and ready for deployment."
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

echo "Timeout waiting for VALIDATED state. Proceeding with caution..."
