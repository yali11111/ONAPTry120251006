# tests/integration/test_full_flow.py
def test_full_event_flow(mock_kafka, mock_orchestrator):
    """
    Simulate event production, consumption, and orchestration end-to-end.
    """
    mock_event = {"vnf_id": "vnf-1", "cpu": 90}
    mock_kafka.produce("VNF_SCALE_EVENT", mock_event)
    
    # Consume event
    from event_consumer.consume_event import main
    main()  # should trigger scale workflow
    
    # Verify orchestrator called
    assert mock_orchestrator.scale_vnf_called_with == ("vnf-1", "out")
