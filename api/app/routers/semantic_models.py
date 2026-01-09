"""
FastAPI router for semantic model operations.
Provides REST API endpoints for querying metrics, dimensions, and executing queries.
"""

from fastapi import APIRouter, HTTPException, Query, Body
from typing import Optional, List
from pathlib import Path

from app.services.semantic_model_service import SemanticModelService
from app.schemas.semantic_models import QueryRequest, SimpleQueryRequest, ValidationRequest
import app.core.config as config

router = APIRouter()

# Initialize service with explicit paths
# Project dir: go up from api/app/routers to dwh/
#project_dir = Path(__file__).parent.parent.parent
project_dir = Path(config.settings.DBT_PROJECT_DIR)
venv_path = project_dir.parent / config.settings.Config.env_file

semantic_service = SemanticModelService(
    project_dir=str(project_dir),
    venv_path=str(venv_path) if venv_path.exists() else None
)


# Endpoints

@router.get("/metrics")
async def list_metrics(
    search: Optional[str] = Query(None, description="Filter metrics by search term"),
    show_all_dimensions: bool = Query(False, description="Show all dimensions for each metric")
):
    """
    List all available metrics with their dimensions.
    
    - **search**: Optional search term to filter metrics
    - **show_all_dimensions**: Include all dimensions in the response
    """
    result = semantic_service.list_metrics(search=search, show_all_dimensions=show_all_dimensions)
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.get("/metrics/{metric_name}")
async def get_metric_details(metric_name: str):
    """
    Get detailed information about a specific metric.
    
    - **metric_name**: Name of the metric to retrieve
    """
    result = semantic_service.get_metric_details(metric_name)
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.get("/dimensions")
async def list_dimensions(
    metrics: List[str] = Query(..., description="Metrics to get dimensions for")
):
    """
    List all unique dimensions for specified metrics.
    
    - **metrics**: List of metric names (returns intersection of dimensions)
    """
    result = semantic_service.list_dimensions(metrics=metrics)
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.get("/dimension-values")
async def list_dimension_values(
    dimension: str = Query(..., description="Dimension to query values from"),
    metrics: List[str] = Query(..., description="Metrics associated with the dimension"),
    start_time: Optional[str] = Query(None, description="ISO8601 start time"),
    end_time: Optional[str] = Query(None, description="ISO8601 end time")
):
    """
    List all values for a specific dimension.
    
    - **dimension**: Name of the dimension
    - **metrics**: List of metrics that use this dimension
    - **start_time**: Optional time filter start
    - **end_time**: Optional time filter end
    """
    result = semantic_service.list_dimension_values(
        dimension=dimension,
        metrics=metrics,
        start_time=start_time,
        end_time=end_time
    )
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.get("/entities")
async def list_entities(
    metrics: Optional[List[str]] = Query(None, description="Optional metrics to filter entities")
):
    """
    List all unique entities.
    
    - **metrics**: Optional list of metrics to filter entities by
    """
    result = semantic_service.list_entities(metrics=metrics)
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.get("/saved-queries")
async def list_saved_queries(
    show_exports: bool = Query(False, description="Show exports for each saved query"),
    show_parameters: bool = Query(False, description="Show full query parameters")
):
    """
    List all available saved queries.
    
    - **show_exports**: Include export configurations
    - **show_parameters**: Include full query parameters
    """
    result = semantic_service.list_saved_queries(
        show_exports=show_exports,
        show_parameters=show_parameters
    )
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.post("/query")
async def query_metrics(request: QueryRequest = Body(...)):
    """
    Execute a query against semantic models.
    
    Supports querying metrics with dimensions, filters, ordering, and limits.
    Can also execute saved queries.
    
    Example request body:
    ```json
    {
        "metrics": ["total_revenue", "order_count"],
        "group_by": ["metric_time__month", "customer_id"],
        "where": ["{{ Dimension('customer_id') }} > 100"],
        "order_by": ["-metric_time"],
        "limit": 50
    }
    ```
    """
    result = semantic_service.query(
        metrics=request.metrics,
        group_by=request.group_by,
        where=request.where,
        order_by=request.order_by,
        limit=request.limit,
        start_time=request.start_time,
        end_time=request.end_time,
        saved_query=request.saved_query,
        compile_sql=request.compile_sql
    )
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.post("/query/simple")
async def query_metrics_simple(request: SimpleQueryRequest = Body(...)):
    """
    Execute a simplified query with automatic filter formatting.
    
    This endpoint provides a more user-friendly interface for common queries.
    
    Example request body:
    ```json
    {
        "metrics": ["total_revenue"],
        "dimensions": ["customer_id"],
        "filters": {
            "customer_id": {"operator": ">", "value": "100"}
        },
        "time_grain": "month",
        "limit": 50
    }
    ```
    """
    result = semantic_service.query_with_filters(
        metrics=request.metrics,
        dimensions=request.dimensions,
        filters=request.filters,
        time_grain=request.time_grain,
        limit=request.limit
    )
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.post("/validate")
async def validate_configs(request: ValidationRequest = Body(...)):
    """
    Validate semantic model configurations.
    
    Performs validation checks against defined semantic models and optionally
    validates against the data warehouse.
    """
    result = semantic_service.validate(
        skip_dw=request.skip_dw,
        show_all=request.show_all,
        verbose_issues=request.verbose_issues,
        dw_timeout=request.dw_timeout
    )
    
    if not result["success"]:
        raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
    
    return result["data"]


@router.get("/health")
async def health_check():
    """
    Perform health check against the data platform.
    
    Verifies that the MetricFlow service can connect to the configured
    data warehouse.
    """
    result = semantic_service.health_checks()
    
    if not result["success"]:
        raise HTTPException(status_code=503, detail=result.get("error", "Health check failed"))
    
    return {"status": "healthy", "details": result["data"]}
