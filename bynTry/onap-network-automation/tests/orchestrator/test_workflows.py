# tests/orchestrator/test_workflows.py
import pytest
from orchestrator.workflows.scale_workflow import scale_vnf

def test_scale_vnf_workflow():
    result = scale_vnf("vnf-1", "out")
    assert result["vnf_id"] == "vnf-1"
    assert result["status"] == "success"
