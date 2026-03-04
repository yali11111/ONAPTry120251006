# api/rest/endpoints/heal.py
from fastapi import APIRouter, HTTPException
from orchestrator.workflows.heal_workflow import heal_vnf

router = APIRouter()

@router.post("/")
def trigger_heal(vnf_id: str):
    try:
        heal_vnf(vnf_id)
        return {"vnf_id": vnf_id, "status": "healing triggered"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
