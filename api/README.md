# dbt Semantic Model API

A clean FastAPI application for serving dbt semantic models through REST endpoints.

## Features

- 🚀 **FastAPI**: Modern, fast web framework for building APIs
- 📊 **Semantic Model Integration**: Direct integration with dbt semantic models
- 🔍 **Query API**: Execute queries against semantic models with filtering and grouping
- 📈 **Metrics Discovery**: Browse and search available metrics
- 🎯 **Clean Architecture**: Separation of concerns with routers, services, and schemas
- ⚡ **Async Support**: Asynchronous request handling for better performance

## Project Structure

```
api/
├── main.py                 # FastAPI application entry point
├── requirements.txt        # Python dependencies
├── .env.example           # Environment configuration template
├── README.md              # This file
└── app/
    ├── __init__.py
    ├── core/              # Core configuration
    │   ├── __init__.py
    │   └── config.py      # Settings and configuration
    ├── routers/           # API route handlers
    │   ├── __init__.py
    │   └── semantic_models.py
    ├── schemas/           # Pydantic models for validation
    │   ├── __init__.py
    │   └── semantic_models.py
    └── services/          # Business logic layer
        ├── __init__.py
        └── semantic_model_service.py
```

## Setup

### Prerequisites

- Python 3.9+
- dbt project compiled (run `dbt compile` in the `dwh/` directory)
- PostgreSQL database (for production queries)

### Installation

1. Create and activate a virtual environment:

```bash
cd api
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Configure environment:

```bash
cp .env.example .env
# Edit .env with your actual configuration
```

4. Ensure dbt project is compiled:

```bash
cd ../dwh
dbt compile
cd ../api
```

## Running the API

### Development Mode

```bash
python main.py
```

Or using uvicorn directly:

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`

### API Documentation

Once running, visit:

- **Interactive API docs (Swagger UI)**: http://localhost:8000/docs
- **Alternative API docs (ReDoc)**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## API Endpoints

### Health Check

- `GET /` - Root endpoint
- `GET /health` - Health check

### Semantic Models

- `GET /api/v1/semantic-models/` - List all semantic models
- `GET /api/v1/semantic-models/{model_name}` - Get specific semantic model details
- `GET /api/v1/semantic-models/{model_name}/metrics` - Get metrics for a model
- `POST /api/v1/semantic-models/query` - Execute a query against semantic models
- `GET /api/v1/semantic-models/metrics/` - List all available metrics

### Example Query Request

```bash
curl -X POST "http://localhost:8000/api/v1/semantic-models/query" \
  -H "Content-Type: application/json" \
  -d '{
    "metrics": ["total_revenue", "order_count"],
    "group_by": ["date", "store_id"],
    "where": [
      {
        "dimension": "date",
        "operator": "gte",
        "value": "2024-01-01"
      }
    ],
    "order_by": ["date"],
    "limit": 100
  }'
```

## Development

### Code Structure

- **Routers**: Handle HTTP requests and responses
- **Services**: Business logic and dbt integration
- **Schemas**: Pydantic models for request/response validation
- **Core**: Application configuration and settings

### Adding New Endpoints

1. Define schemas in `app/schemas/`
2. Implement service methods in `app/services/`
3. Create router endpoints in `app/routers/`
4. Register router in `main.py`

## Production Deployment

For production deployment:

1. Set `reload=False` in uvicorn configuration
2. Use a production ASGI server (e.g., gunicorn with uvicorn workers)
3. Configure proper CORS origins
4. Set up environment variables securely
5. Enable HTTPS/TLS
6. Add authentication/authorization as needed

Example production command:

```bash
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## License

MIT
