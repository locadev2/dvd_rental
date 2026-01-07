# dbt Tests Documentation

This folder contains comprehensive tests for the data warehouse models.

## Test Structure

### Schema-based Tests
These tests are defined in YAML files and leverage dbt's built-in testing framework:

- **facts_schema_tests.yml** - Tests for fact tables
- **dimensions_schema_tests.yml** - Tests for dimension tables

### Custom SQL Tests
Custom tests written as SQL queries that return failing records:

#### Fact Table Tests
- **test_fact_sales_no_pk_duplicates.sql** - Validates primary key uniqueness
- **test_fact_sales_date_logic.sql** - Ensures rental dates precede return dates
- **test_fact_sales_positive_amounts.sql** - Validates all amounts are positive
- **test_fact_sales_referential_integrity.sql** - Checks all foreign keys exist in dimensions

#### Dimension Table Tests
- **test_dim_customer_one_current_record.sql** - Validates SCD Type 2: one current record per customer
- **test_dim_customer_no_overlapping_periods.sql** - Ensures no temporal overlaps in SCD Type 2
- **test_dim_calendar_no_gaps.sql** - Validates continuous date coverage in calendar

## Test Categories

### 1. Primary Key Tests (PK)
✅ **Not Null**: Ensures PKs are never null
✅ **Unique**: Validates no duplicate PKs exist

**Covered Models:**
- fact_sales.rental_id
- dim_customer.customer_key
- dim_film.film_id
- dim_store.store_id
- dim_calendar.date_key

### 2. Foreign Key Tests (FK)
✅ **Not Null**: Ensures FKs are never null
✅ **Relationships**: Validates referential integrity

**Covered Relationships:**
- fact_sales.film_id → dim_film.film_id
- fact_sales.customer_key → dim_customer.customer_key
- fact_sales.store_id → dim_store.store_id
- fact_sales.rental_date_key → dim_calendar.date_key
- fact_sales.return_date_key → dim_calendar.date_key

### 3. Business Logic Tests
✅ **Accepted Values**: Validates data against allowed value lists
✅ **Accepted Range**: Ensures numeric values fall within expected ranges
✅ **Expression Validation**: Tests complex business rules

**Examples:**
- Amount values must be positive (fact_sales)
- Rental dates must precede return dates (fact_sales)
- Film ratings must be valid (G, PG, PG-13, R, NC-17)
- Rental duration between 1-30 days
- Day of week between 0-6

### 4. Data Quality Tests
✅ **SCD Type 2 Validation**: Ensures proper slowly changing dimension implementation
✅ **Temporal Integrity**: Validates date logic and continuity
✅ **Orphaned Record Detection**: Identifies records without valid dimension references

## Running Tests

Run all tests:
```bash
dbt test
```

Run tests for specific model:
```bash
dbt test --select fact_sales
dbt test --select dim_customer
```

Run tests by type:
```bash
dbt test --select test_type:generic
dbt test --select test_type:singular
```

Run specific test:
```bash
dbt test --select test_fact_sales_no_pk_duplicates
```

## Test Severity Levels

- **error** (default): Test failure stops execution
- **warn**: Test failure logs warning but continues

Tests with `warn` severity are typically for data quality issues that don't break functionality.

## Adding New Tests

### Schema-based Test
Add to the appropriate YAML file:
```yaml
- name: column_name
  tests:
    - not_null
    - unique
```

### Custom SQL Test
Create a new SQL file that returns failing records:
```sql
-- test_my_custom_test.sql
select *
from {{ ref('my_model') }}
where condition_that_should_not_be_true
```

## Dependencies

Some tests use dbt_utils package for advanced testing:
- `dbt_utils.accepted_range`
- `dbt_utils.expression_is_true`

Ensure dbt_utils is installed in your project.
