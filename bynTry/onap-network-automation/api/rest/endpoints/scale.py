# api/rest/endpoints/scale.py
from fastapi import APIRouter, HTTPException
from orchestrator.workflows.scale_workflow import scale_vnf

router = APIRouter()

@router.post("/")
def trigger_scale(vnf_id: str, scale_type: str):
    try:
        scale_vnf(vnf_id, scale_type)
        return {"vnf_id": vnf_id, "scale_type": scale_type, "status": "triggered"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
