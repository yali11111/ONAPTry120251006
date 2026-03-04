#!/usr/bin/env bash
set -euo pipefail

echo "Starting ACM cleanup..."

# ----------------------------
# Validate required variables
# ----------------------------
: "${ONAP_HOST:?ONAP_HOST not set}"
: "${ONAP_USER:?ONAP_USER not set}"
: "${ONAP_PASSWORD:?ONAP_PASSWORD not set}"

# Optional (may not exist if earlier step failed)
COMPOSITION_ID="${COMPOSITION_ID:-}"
INSTANCE_ID="${INSTANCE_ID:-}"

AUTH="-u ${ONAP_USER}:${ONAP_PASSWORD}"

# ----------------------------
# Helper: API Call
# ----------------------------
api_call() {
  local method=$1
  local url=$2
  echo "API: $method $url"
  curl -s -o /dev/null -w "%{http_code}" \
       $AUTH \
       -X "$method" \
       "$url"
}

# ----------------------------
# Undeploy Instance (if exists)
# ----------------------------
if [[ -n "$INSTANCE_ID" ]]; then
  echo "Undeploying instance: $INSTANCE_ID"

  api_call POST \
    "${ONAP_HOST}/onap/automationcomposition/v1/instances/${INSTANCE_ID}/undeploy" || true

  sleep 5
fi

# ----------------------------
# Delete Instance
# ----------------------------
if [[ -n "$INSTANCE_ID" ]]; then
  echo "Deleting instance: $INSTANCE_ID"

  api_call DELETE \
    "${ONAP_HOST}/onap/automationcomposition/v1/instances/${INSTANCE_ID}" || true
fi

# ----------------------------
# Delete Composition
# ----------------------------
if [[ -n "$COMPOSITION_ID" ]]; then
  echo "Deleting composition: $COMPOSITION_ID"

  api_call DELETE \
    "${ONAP_HOST}/onap/automationcomposition/v1/compositions/${COMPOSITION_ID}" || true
fi

# ----------------------------
# Remove temporary files
# ----------------------------
rm -f composition_id.txt instance_id.txt || true

echo "ACM cleanup completed."
