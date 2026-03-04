# api/rest/app.py
from fastapi import FastAPI
from .endpoints import health, scale, heal

app = FastAPI(title="5G Network Orchestrator API", version="1.0.0")

# Register endpoints
app.include_router(health.router, prefix="/health", tags=["Health"])
app.include_router(scale.router, prefix="/scale", tags=["Scaling"])
app.include_router(heal.router, prefix="/heal", tags=["Healing"])

# Optionally add middleware for logging, auth, or metrics
