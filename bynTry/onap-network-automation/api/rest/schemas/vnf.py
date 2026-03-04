# api/rest/schemas/vnf.py
from pydantic import BaseModel

class ScaleRequest(BaseModel):
    vnf_id: str
    scale_type: str

class HealRequest(BaseModel):
    vnf_id: str
