#!/usr/bin/env bash
set -euo pipefail

echo "Starting full ACM deployment to ONAP..."

# ----------------------------
# Validate required environment variables
# ----------------------------
: "${ONAP_HOST:?ONAP_HOST not set}"
: "${ONAP_USER:?ONAP_USER not set}"
: "${ONAP_PASSWORD:?ONAP_PASSWORD not set}"
: "${COMPOSITION_FILE:?COMPOSITION_FILE not set}"

AUTH="-u ${ONAP_USER}:${ONAP_PASSWORD}"
BASE_URL="${ONAP_HOST}/onap/automationcomposition/v1"

INSTANCE_NAME="${INSTANCE_NAME:-acm-instance-$(date +%s)}"

# ----------------------------
# Step 1: Upload TOSCA composition
# ----------------------------
echo "Uploading composition: ${COMPOSITION_FILE}"

COMPOSITION_ID=$(curl -s \
  ${AUTH} \
  -X POST \
  -F "file=@${COMPOSITION_FILE}" \
  "${BASE_URL}/compositions" \
  | jq -r '.compositionId')

if [[ -z "$COMPOSITION_ID" || "$COMPOSITION_ID" == "null" ]]; then
  echo "Failed to upload composition."
  exit 1
fi

echo "Composition uploaded. ID: $COMPOSITION_ID"
echo "$COMPOSITION_ID" > composition_id.txt

# ----------------------------
# Step 2: Instantiate ACM
# ----------------------------
echo "Instantiating ACM instance: $INSTANCE_NAME"

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

echo "Instance created. ID: $INSTANCE_ID"
echo "$INSTANCE_ID" > instance_id.txt

# ----------------------------
# Step 3: Deploy ACM instance
# ----------------------------
echo "Deploying ACM instance..."
export ONAP_HOST
export ONAP_USER
export ONAP_PASSWORD
export INSTANCE_ID

bash scripts/deploy_acm.sh

echo "ACM deployment completed successfully."
