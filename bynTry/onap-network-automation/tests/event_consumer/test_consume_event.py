# tests/event_consumer/test_consume_event.py
import pytest
from unittest.mock import patch, MagicMock
from event_consumer.consume_event import main

@patch("event_consumer.consume_event.KafkaConsumer")
def test_consume_event_calls_handlers(mock_consumer):
    # Setup mock KafkaConsumer
    mock_message = MagicMock()
    mock_message.key.decode.return_value = "VNF_SCALE_EVENT"
    mock_message.value = {"vnf_id": "vnf-1", "cpu": 85}
    mock_consumer.return_value = [mock_message]

    # Patch handlers
    with patch("event_consumer.consume_event.ScaleHandler.handle") as mock_handler:
        main()
        mock_handler.assert_called_once_with(mock_message.value)
