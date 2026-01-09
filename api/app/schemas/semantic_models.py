"""
Pydantic models for semantic model API requests and responses.
"""

from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field


class QueryRequest(BaseModel):
    """Request model for querying metrics."""
    metrics: Optional[List[str]] = Field(None, description="List of metrics to query")
    group_by: Optional[List[str]] = Field(None, description="Dimensions to group by")
    where: Optional[List[str]] = Field(None, description="Where clause conditions")
    order_by: Optional[List[str]] = Field(None, description="Fields to order by (prefix with - for DESC)")
    limit: Optional[int] = Field(None, description="Maximum number of rows")
    start_time: Optional[str] = Field(None, description="ISO8601 timestamp for start time")
    end_time: Optional[str] = Field(None, description="ISO8601 timestamp for end time")
    saved_query: Optional[str] = Field(None, description="Name of saved query to execute")
    compile_sql: bool = Field(False, description="Show compiled SQL")


class SimpleQueryRequest(BaseModel):
    """Simplified query request with filters."""
    metrics: List[str] = Field(..., description="List of metrics to query")
    dimensions: Optional[List[str]] = Field(None, description="Dimensions to group by")
    filters: Optional[Dict[str, Any]] = Field(None, description="Dimension filters")
    time_grain: Optional[str] = Field(None, description="Time granularity (day, week, month, quarter, year)")
    limit: int = Field(100, description="Maximum number of rows")


class ValidationRequest(BaseModel):
    """Request model for validation."""
    skip_dw: bool = Field(False, description="Skip data warehouse validations")
    show_all: bool = Field(False, description="Show all warnings and errors")
    verbose_issues: bool = Field(False, description="Show verbose issue details")
    dw_timeout: Optional[int] = Field(None, description="Data warehouse timeout in seconds")
