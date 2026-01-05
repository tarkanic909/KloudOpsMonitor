from fastapi import FastAPI

from app.config import settings
from app.api.health import router as health_router

app = FastAPI(title=settings.app_name)

# API routes
app.include_router(health_router)

@app.on_event("startup")
def startup():
    print(f"Starting backend in {settings.env} mode")
    

@app.on_event("shutdown")
def shutdown():
    print("Backend shutting down")