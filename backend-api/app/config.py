from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    env: str = "dev"
    app_name: str = "kloudops-backend"
    
    class Config:
        env_file = ".env"
        
settings = Settings() 