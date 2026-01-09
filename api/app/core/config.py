"""Configuration settings for the API."""

from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """Application settings."""
    
    ROOT_NAME: str = "DWH API"
    API_V1_STR: str = "/api/v1"
    API_V2_STR: str = "/api/v2"
    PROJECT_NAME: str = "dbt Semantic Model API"
    VERSION: str = "1.0.0"
    
    # CORS
    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8000"]
    
    # dbt configuration
    DBT_PROJECT_DIR: str = "/home/paul/workspace/dbt/dwh"
    DBT_MANIFEST_PATH: str = f"{DBT_PROJECT_DIR}/target/manifest.json"
    DBT_SEMANTIC_MANIFEST_PATH: str = f"{DBT_MANIFEST_PATH}/semantic_manifest.json"
    
    # Database
    DATABASE_URL: str = "postgresql://user:password@localhost:5432/dvd_rental"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
