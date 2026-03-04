# tests/event_consumer/test_handlers.py
import pytest
from event_consumer.handlers.scale_handler import ScaleHandler

def test_scale_handler():
    handler = ScaleHandler()
    payload = {"vnf_id": "vnf-1", "scale_type": "out"}
    result = handler.handle(payload)
    assert result["status"] == "success"
