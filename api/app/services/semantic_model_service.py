"""
Service for interacting with dbt MetricFlow commands.
Wraps MetricFlow CLI commands for querying semantic models, metrics, and dimensions.
"""

import subprocess
import json
import os
from typing import Optional, List, Dict, Any
from pathlib import Path


class SemanticModelService:
    """Service for executing MetricFlow commands against dbt semantic models."""
    
    def __init__(self, project_dir: Optional[str] = None, venv_path: Optional[str] = None):
        """
        Initialize the semantic model service.
        
        Args:
            project_dir: Path to the dbt project directory. If None, uses current directory.
            venv_path: Path to the virtual environment. If None, tries to detect it.
        """
        self.project_dir = Path(project_dir) if project_dir else Path.cwd()
        
        # Determine the mf command path
        if venv_path:
            self.mf_command = str(Path(venv_path) / "bin" / "mf")
        else:
            # Try to find mf in the virtual environment relative to project
            potential_venv = self.project_dir.parent / ".venv"
            if (potential_venv / "bin" / "mf").exists():
                self.mf_command = str(potential_venv / "bin" / "mf")
            else:
                # Fall back to system mf command
                self.mf_command = "mf"
    
    def _run_command(self, command: List[str]) -> Dict[str, Any]:
        """
        Execute a MetricFlow command and return the result.
        
        Args:
            command: List of command arguments
            
        Returns:
            Dictionary containing success status and data or error message
        """
        try:
            # Replace 'mf' with the full path to the command
            if command[0] == "mf":
                command[0] = self.mf_command
            
            # Set up environment - copy current env to preserve HOME and dbt profiles
            env = os.environ.copy()
            
            result = subprocess.run(
                command,
                cwd=self.project_dir,
                capture_output=True,
                text=True,
                check=True,
                env=env
            )
            
            # Try to parse JSON output
            try:
                data = json.loads(result.stdout)
                return {"success": True, "data": data}
            except json.JSONDecodeError:
                # Return raw text if not JSON
                return {"success": True, "data": result.stdout}
                
        except subprocess.CalledProcessError as e:
            return {
                "success": False,
                "error": e.stderr or e.stdout,
                "exit_code": e.returncode
            }
        except Exception as e:
            return {"success": False, "error": str(e)}
    
    def list_metrics(self, search: Optional[str] = None, show_all_dimensions: bool = False) -> Dict[str, Any]:
        """
        List all metrics with their available dimensions.
        
        Args:
            search: Filter metrics by search term
            show_all_dimensions: Show all dimensions associated with metrics
            
        Returns:
            Dictionary with metrics data
        """
        command = ["mf", "list", "metrics"]
        
        if search:
            command.extend(["--search", search])
        
        if show_all_dimensions:
            command.append("--show-all-dimensions")
        
        return self._run_command(command)
    
    def list_dimensions(self, metrics: List[str]) -> Dict[str, Any]:
        """
        List all unique dimensions for specified metrics.
        
        Args:
            metrics: List of metric names to get dimensions for
            
        Returns:
            Dictionary with dimensions data
        """
        command = ["mf", "list", "dimensions", "--metrics", ",".join(metrics)]
        return self._run_command(command)
    
    def list_dimension_values(
        self,
        dimension: str,
        metrics: List[str],
        start_time: Optional[str] = None,
        end_time: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        List dimension values for specified metrics.
        
        Args:
            dimension: Dimension to query values from
            metrics: List of metrics associated with the dimension
            start_time: Optional ISO8601 timestamp to constraint start time
            end_time: Optional ISO8601 timestamp to constraint end time
            
        Returns:
            Dictionary with dimension values
        """
        command = [
            "mf", "list", "dimension-values",
            "--dimension", dimension,
            "--metrics", ",".join(metrics)
        ]
        
        if start_time:
            command.extend(["--start-time", start_time])
        
        if end_time:
            command.extend(["--end-time", end_time])
        
        return self._run_command(command)
    
    def list_entities(self, metrics: Optional[List[str]] = None) -> Dict[str, Any]:
        """
        List all unique entities.
        
        Args:
            metrics: Optional list of metrics to filter entities
            
        Returns:
            Dictionary with entities data
        """
        command = ["mf", "list", "entities"]
        
        if metrics:
            command.extend(["--metrics", ",".join(metrics)])
        
        return self._run_command(command)
    
    def list_saved_queries(self, show_exports: bool = False, show_parameters: bool = False) -> Dict[str, Any]:
        """
        List all available saved queries.
        
        Args:
            show_exports: Show exports listed under each saved query
            show_parameters: Show full query parameters for each saved query
            
        Returns:
            Dictionary with saved queries data
        """
        command = ["mf", "list", "saved-queries"]
        
        if show_exports:
            command.append("--show-exports")
        
        if show_parameters:
            command.append("--show-parameters")
        
        return self._run_command(command)
    
    def query(
        self,
        metrics: Optional[List[str]] = None,
        group_by: Optional[List[str]] = None,
        where: Optional[List[str]] = None,
        order_by: Optional[List[str]] = None,
        limit: Optional[int] = None,
        start_time: Optional[str] = None,
        end_time: Optional[str] = None,
        saved_query: Optional[str] = None,
        compile_sql: bool = False,
        output_csv: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Execute a query against semantic models.
        
        Args:
            metrics: List of metrics to query
            group_by: List of dimensions/entities to group by
            where: List of where clause conditions
            order_by: List of fields to order by (prefix with - for DESC)
            limit: Limit number of rows returned
            start_time: Optional ISO8601 timestamp for start time filter
            end_time: Optional ISO8601 timestamp for end time filter
            saved_query: Name of saved query to execute
            compile_sql: Show the SQL that will be executed
            output_csv: Optional file path to export results to CSV
            
        Returns:
            Dictionary with query results
        """
        command = ["mf", "query"]
        
        if saved_query:
            command.extend(["--saved-query", saved_query])
        else:
            if not metrics:
                return {"success": False, "error": "Either metrics or saved_query must be provided"}
            
            command.extend(["--metrics", ",".join(metrics)])
        
        if group_by:
            command.extend(["--group-by", ",".join(group_by)])
        
        if where:
            for condition in where:
                command.extend(["--where", condition])
        
        if order_by:
            command.extend(["--order-by", ",".join(order_by)])
        
        if limit:
            command.extend(["--limit", str(limit)])
        
        if start_time:
            command.extend(["--start-time", start_time])
        
        if end_time:
            command.extend(["--end-time", end_time])
        
        if compile_sql:
            command.append("--explain")
        
        if output_csv:
            command.extend(["--csv", output_csv])
        
        return self._run_command(command)
    
    def validate(
        self,
        skip_dw: bool = False,
        show_all: bool = False,
        verbose_issues: bool = False,
        dw_timeout: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Validate semantic model configurations.
        
        Args:
            skip_dw: Skip data warehouse validations
            show_all: Print warnings and future errors
            verbose_issues: Print extra details about issues
            dw_timeout: Optional timeout for data warehouse validation
            
        Returns:
            Dictionary with validation results
        """
        command = ["mf", "validate-configs"]
        
        if skip_dw:
            command.append("--skip-dw")
        
        if show_all:
            command.append("--show-all")
        
        if verbose_issues:
            command.append("--verbose-issues")
        
        if dw_timeout:
            command.extend(["--dw-timeout", str(dw_timeout)])
        
        return self._run_command(command)
    
    def health_checks(self) -> Dict[str, Any]:
        """
        Perform health check against the data platform.
        
        Returns:
            Dictionary with health check results
        """
        command = ["mf", "health-checks"]
        return self._run_command(command)
    
    def get_metric_details(self, metric_name: str) -> Dict[str, Any]:
        """
        Get detailed information about a specific metric.
        
        Args:
            metric_name: Name of the metric
            
        Returns:
            Dictionary with metric details
        """
        return self.list_metrics(search=metric_name, show_all_dimensions=True)
    
    def query_with_filters(
        self,
        metrics: List[str],
        dimensions: Optional[List[str]] = None,
        filters: Optional[Dict[str, Any]] = None,
        time_grain: Optional[str] = None,
        limit: int = 100
    ) -> Dict[str, Any]:
        """
        Convenience method to query metrics with common filtering patterns.
        
        Args:
            metrics: List of metrics to query
            dimensions: List of dimensions to group by
            filters: Dictionary of dimension filters
            time_grain: Time granularity (day, week, month, quarter, year)
            limit: Maximum number of rows to return
            
        Returns:
            Dictionary with query results
        """
        group_by = dimensions or []
        
        # Add time grain to metric_time if specified
        if time_grain:
            group_by.append(f"metric_time__{time_grain}")
        elif "metric_time" not in group_by:
            group_by.append("metric_time")
        
        # Build where clauses from filters
        where_clauses = []
        if filters:
            for dim, value in filters.items():
                if isinstance(value, dict):
                    operator = value.get("operator", "=")
                    val = value.get("value")
                    where_clauses.append(f"{{{{ Dimension('{dim}') }}}} {operator} '{val}'")
                else:
                    where_clauses.append(f"{{{{ Dimension('{dim}') }}}} = '{value}'")
        
        return self.query(
            metrics=metrics,
            group_by=group_by,
            where=where_clauses if where_clauses else None,
            limit=limit
        )
