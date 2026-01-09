"""
Example API calls for testing the semantic model endpoints.

This script demonstrates how to interact with the API using the requests library.
Make sure the API server is running before executing these examples.

Run with: python tests/api_calls.py
"""

import requests
import json
from typing import Optional

# API Base URL
BASE_URL = "http://localhost:8000"
API_V1 = f"{BASE_URL}/api/v1"
SEMANTIC_API = f"{API_V1}/semantic-models"


def print_response(func):
    """Pretty print API response."""
    def wrapper(*args, **kwargs):
        print(f"{'='*60}")
        print(f"Testing: {func.__name__}")
        print(f"{'='*60}")
        
        response = func(*args, **kwargs)
        print(f"Status Code: {response.status_code}")
        
        try:
            data = response.json()
            print(f"\nResponse:\n{json.dumps(data, indent=2)}")
        except json.JSONDecodeError:
            print(f"Response Text: {response.text}")
        
        print("\n")
        return response
    return wrapper

@print_response
def root_check():
    """Test root path."""
    response = requests.get(f"{BASE_URL}")
    return response

@print_response
def test_list_metrics():
    """Test listing all metrics."""
    response = requests.get(f"{SEMANTIC_API}/metrics")
    return response


@print_response
def test_list_metrics_with_search():
    """Test listing metrics with search filter."""
    response = requests.get(
        f"{SEMANTIC_API}/metrics",
        params={"search": "revenue", "show_all_dimensions": True}
    )
    return response


@print_response
def test_get_metric_details():
    """Test getting details for a specific metric."""
    metric_name = "total_revenue"  # Replace with actual metric name
    response = requests.get(f"{SEMANTIC_API}/metrics/{metric_name}")
    return response


@print_response
def test_list_dimensions():
    """Test listing dimensions for metrics."""
    response = requests.get(
        f"{SEMANTIC_API}/dimensions",
        params={"metrics": ["total_revenue", "order_count"]}
    )
    return response


@print_response
def test_list_dimension_values():
    """Test listing dimension values."""
    response = requests.get(
        f"{SEMANTIC_API}/dimension-values",
        params={
            "dimension": "customer_id",
            "metrics": ["total_revenue"]
        }
    )
    return response


@print_response
def test_list_dimension_values_with_time():
    """Test listing dimension values with time filters."""
    response = requests.get(
        f"{SEMANTIC_API}/dimension-values",
        params={
            "dimension": "customer_id",
            "metrics": ["total_revenue"],
            "start_time": "2024-01-01T00:00:00",
            "end_time": "2024-12-31T23:59:59"
        }
    )
    return response


@print_response
def test_list_entities():
    """Test listing all entities."""
    response = requests.get(f"{SEMANTIC_API}/entities")
    return response


@print_response
def test_list_entities_filtered():
    """Test listing entities filtered by metrics."""
    response = requests.get(
        f"{SEMANTIC_API}/entities",
        params={"metrics": ["total_revenue"]}
    )
    return response


@print_response
def test_list_saved_queries():
    """Test listing saved queries."""
    response = requests.get(f"{SEMANTIC_API}/saved-queries")
    return response


@print_response
def test_list_saved_queries_with_details():
    """Test listing saved queries with exports and parameters."""
    response = requests.get(
        f"{SEMANTIC_API}/saved-queries",
        params={"show_exports": True, "show_parameters": True}
    )
    return response


@print_response
def test_query_metrics():
    """Test querying metrics with full parameters."""
    query_data = {
        "metrics": ["total_revenue", "order_count"],
        "group_by": ["metric_time__month"],
        "order_by": ["-metric_time"],
        "limit": 10
    }
    response = requests.post(
        f"{SEMANTIC_API}/query",
        json=query_data
    )
    return response


@print_response
def test_query_metrics_with_filters():
    """Test querying metrics with where clause."""
    query_data = {
        "metrics": ["total_revenue"],
        "group_by": ["metric_time__day", "customer_id"],
        "where": ["{{ Dimension('customer_id') }} > 100"],
        "order_by": ["-metric_time"],
        "limit": 20
    }
    response = requests.post(
        f"{SEMANTIC_API}/query",
        json=query_data
    )
    return response


@print_response
def test_query_metrics_with_time_range():
    """Test querying metrics with time range filters."""
    query_data = {
        "metrics": ["total_revenue"],
        "group_by": ["metric_time__week"],
        "start_time": "2024-01-01",
        "end_time": "2024-12-31",
        "order_by": ["-metric_time"],
        "limit": 50
    }
    response = requests.post(
        f"{SEMANTIC_API}/query",
        json=query_data
    )
    return response


@print_response
def test_query_saved_query():
    """Test querying a saved query."""
    query_data = {
        "saved_query": "customer_orders",  # Replace with actual saved query name
        "limit": 10
    }
    response = requests.post(
        f"{SEMANTIC_API}/query",
        json=query_data
    )
    return response


@print_response
def test_query_with_compile_sql():
    """Test querying with SQL compilation."""
    query_data = {
        "metrics": ["total_revenue"],
        "group_by": ["metric_time__month"],
        "compile_sql": True,
        "limit": 5
    }
    response = requests.post(
        f"{SEMANTIC_API}/query",
        json=query_data
    )
    return response


@print_response
def test_query_simple():
    """Test simplified query endpoint."""
    query_data = {
        "metrics": ["total_revenue"],
        "dimensions": ["customer_id"],
        "time_grain": "month",
        "limit": 10
    }
    response = requests.post(
        f"{SEMANTIC_API}/query/simple",
        json=query_data
    )
    return response


@print_response
def test_query_simple_with_filters():
    """Test simplified query with filters."""
    query_data = {
        "metrics": ["total_revenue", "order_count"],
        "dimensions": ["customer_id"],
        "filters": {
            "customer_id": {"operator": ">", "value": "100"}
        },
        "time_grain": "week",
        "limit": 25
    }
    response = requests.post(
        f"{SEMANTIC_API}/query/simple",
        json=query_data
    )
    return response


@print_response
def test_validate_configs():
    """Test semantic model validation."""
    validation_data = {
        "skip_dw": False,
        "show_all": True,
        "verbose_issues": True
    }
    response = requests.post(
        f"{SEMANTIC_API}/validate",
        json=validation_data
    )
    return response


@print_response
def test_validate_configs_skip_dw():
    """Test validation without data warehouse checks."""
    validation_data = {
        "skip_dw": True,
        "show_all": False,
        "verbose_issues": False
    }
    response = requests.post(
        f"{SEMANTIC_API}/validate",
        json=validation_data
    )
    return response


@print_response
def test_health_check():
    """Test semantic layer health check."""
    response = requests.get(f"{SEMANTIC_API}/health")
    return response


def main():
    """Run all test API calls."""
    print("\n" + "="*80)
    print("SEMANTIC MODEL API TESTS")
    print("="*80 + "\n")
    
    try:
        root_check()

        return
        # Basic listing tests
        print("\n--- LISTING TESTS ---\n")
        test_list_metrics()
        test_list_metrics_with_search()
        test_get_metric_details()
        test_list_dimensions()
        test_list_dimension_values()
        test_list_dimension_values_with_time()
        test_list_entities()
        test_list_entities_filtered()
        test_list_saved_queries()
        test_list_saved_queries_with_details()
        
        # Query tests
        print("\n--- QUERY TESTS ---\n")
        test_query_metrics()
        test_query_metrics_with_filters()
        test_query_metrics_with_time_range()
        test_query_saved_query()
        test_query_with_compile_sql()
        test_query_simple()
        test_query_simple_with_filters()
        
        # Validation and health tests
        print("\n--- VALIDATION & HEALTH TESTS ---\n")
        test_validate_configs()
        test_validate_configs_skip_dw()
        test_health_check()
        
        print("\n" + "="*80)
        print("ALL TESTS COMPLETED")
        print("="*80 + "\n")
        
    except requests.exceptions.ConnectionError:
        print("\n❌ Error: Could not connect to the API.")
        print("Please make sure the API server is running on http://localhost:8000")
        print("Start it with: uvicorn app.main:app --reload")
    except Exception as e:
        print(f"\n❌ Error: {e}")


if __name__ == "__main__":
    main()