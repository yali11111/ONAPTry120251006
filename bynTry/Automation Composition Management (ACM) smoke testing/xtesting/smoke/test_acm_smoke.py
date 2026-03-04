#!/usr/bin/env python3
import yaml
import requests
import time
import os
import pytest

# ----------------------------
# Helper: Load YAML test cases
# ----------------------------
def load_testcases(yaml_file):
    with open(yaml_file, "r") as f:
        return yaml.safe_load(f)["tests"]

# ----------------------------
# Helper: Get ACM instance state
# ----------------------------
def get_instance_state(base_url, instance_id, auth):
    resp = requests.get(f"{base_url}/instances/{instance_id}", auth=auth)
    resp.raise_for_status()
    return resp.json().get("state")

# ----------------------------
# Helper: Validate composition inputs
# ----------------------------
def validate_inputs(base_url, instance_id, expected_inputs, auth):
    resp = requests.get(f"{base_url}/instances/{instance_id}/inputs", auth=auth)
    resp.raise_for_status()
    inputs = resp.json()
    for k, v in expected_inputs.items():
        if inputs.get(k) != v:
            return False, k, inputs.get(k)
    return True, None, None

# ----------------------------
# Main pytest tests
# ----------------------------
@pytest.mark.parametrize("test_case", load_testcases("xtesting/testcases.yaml"))
def test_acm_instance(test_case):
    onap_host = os.environ.get("ONAP_HOST")
    onap_user = os.environ.get("ONAP_USER")
    onap_password = os.environ.get("ONAP_PASSWORD")

    assert onap_host and onap_user and onap_password, "ONAP credentials missing"

    auth = (onap_user, onap_password)
    base_url = f"{onap_host}/onap/automationcomposition/v1"

    # Read instance ID from file
    instance_file = test_case["instance_id_file"]
    with open(instance_file, "r") as f:
        instance_id = f.read().strip()

    timeout = test_case.get("timeout_seconds", 120)
    expected_state = test_case.get("expected_state", "DEPLOYED")
    policy_name = test_case.get("policy_name")
    expected_result = test_case.get("expected_result")
    inputs_to_validate = test_case.get("inputs", {})

    # ----------------------------
    # Wait for expected state
    # ----------------------------
    elapsed = 0
    interval = 5
    while elapsed < timeout:
        state = get_instance_state(base_url, instance_id, auth)
        if state == expected_state:
            break
        if state == "ERROR":
            pytest.fail(f"ACM instance entered ERROR state: {instance_id}")
        time.sleep(interval)
        elapsed += interval
    else:
        pytest.fail(f"Timeout waiting for state {expected_state} (instance {instance_id})")

    # ----------------------------
    # Validate inputs if defined
    # ----------------------------
    if inputs_to_validate:
        valid, key, value = validate_inputs(base_url, instance_id, inputs_to_validate, auth)
        if not valid:
            pytest.fail(f"Input validation failed for {key}: expected {inputs_to_validate[key]}, got {value}")

    # ----------------------------
    # Validate policy execution if defined
    # ----------------------------
    if policy_name and expected_result:
        resp = requests.get(f"{base_url}/instances/{instance_id}/policies/{policy_name}", auth=auth)
        resp.raise_for_status()
        policy_state = resp.json().get("lastExecutionStatus")
        assert policy_state == expected_result, f"Policy {policy_name} execution failed: {policy_state}"
