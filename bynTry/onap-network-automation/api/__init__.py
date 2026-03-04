# api/__init__.py
from fastapi import FastAPI

def create_api_app() -> FastAPI:
    from .rest.app import app
    return app
