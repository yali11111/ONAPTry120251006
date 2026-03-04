#!/usr/bin/env bash
set -euo pipefail

echo "Starting TOSCA upload to ONAP..."

# ----------------------------
# Validate environment variables
# ----------------------------
: "${ONAP_HOST:?ONAP_HOST not set}"
: "${ONAP_USER:?ONAP_USER not set}"
: "${ONAP_PASSWORD:?ONAP_PASSWORD not set}"
: "${COMPOSITION_FILE:?COMPOSITION_FILE not set}"

AUTH="-u ${ONAP_USER}:${ONAP_PASSWORD}"
BASE_URL="${ONAP_HOST}/onap/automationcomposition/v1"

# ----------------------------
# Step 1: Verify file exists
# ----------------------------
if [[ ! -f "$COMPOSITION_FILE" ]]; then
  echo "Composition file not found: $COMPOSITION_FILE"
  exit 1
fi

# ----------------------------
# Step 2: Upload TOSCA composition
# ----------------------------
echo "Uploading composition: $COMPOSITION_FILE"

COMPOSITION_ID=$(curl -s \
  $AUTH \
  -X POST \
  -F "file=@${COMPOSITION_FILE}" \
  "${BASE_URL}/compositions" \
  | jq -r '.compositionId')

if [[ -z "$COMPOSITION_ID" || "$COMPOSITION_ID" == "null" ]]; then
  echo "Failed to upload composition."
  exit 1
fi

echo "Composition uploaded successfully. COMPOSITION_ID=$COMPOSITION_ID"
echo "$COMPOSITION_ID" > composition_id.txt

# ----------------------------
# Step 3: Optional force redeploy
# ----------------------------
if [[ "${FORCE_UPLOAD:-false}" == "true" ]]; then
  echo "Force upload enabled. Deleting old instance if exists..."
  INSTANCE_ID_FILE="instance_id.txt"
  if [[ -f "$INSTANCE_ID_FILE" ]]; then
    INSTANCE_ID=$(cat "$INSTANCE_ID_FILE")
    bash scripts/cleanup.sh
  fi
fi

echo "TOSCA upload completed."
