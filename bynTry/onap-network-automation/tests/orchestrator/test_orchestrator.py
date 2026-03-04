# tests/orchestrator/test_orchestrator.py
import pytest
from orchestrator.orchestrator import Orchestrator

def test_orchestrator_scale_workflow():
    orchestrator = Orchestrator()
    result = orchestrator.scale_vnf("vnf-1", "out")
    assert result["status"] == "triggered"
