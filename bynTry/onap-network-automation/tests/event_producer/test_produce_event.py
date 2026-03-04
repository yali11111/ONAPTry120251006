# tests/event_producer/test_produce_event.py
import pytest
from unittest.mock import patch, MagicMock
from event_producer.produce_event import main

@patch("event_producer.produce_event.KafkaProducer")
def test_event_production(mock_producer_class):
    mock_producer = MagicMock()
    mock_producer_class.return_value = mock_producer
    # Run producer main loop for one iteration
    with patch("event_producer.produce_event.time.sleep", return_value=None):
        with patch("event_producer.produce_event.random.choice", return_value="VNF_SCALE_EVENT"):
            main()
            mock_producer.send.assert_called()
