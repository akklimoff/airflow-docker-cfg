# Airflow Installation Guide

This guide will walk you through installing and running Apache Airflow 3.1.2 using Docker Compose.

## Prerequisites

- Docker installed on your system
- Docker Compose plugin
- At least 4GB of RAM available for Docker
- At least 2 CPUs
- At least 10GB of disk space

## Installation Steps

### 1. Install Docker Compose Plugin

Update your package list and install the Docker Compose plugin:

```bash
sudo apt-get update
sudo apt-get install -y docker-compose-plugin
```

### 2. Clone or Pull the Repository

If you haven't already, clone this repository:

```bash
git clone <repository-url>
cd airflow-cfg
```

Or if you already have it, pull the latest changes:

```bash
git pull
```

### 3. Create Required Directories

Create the necessary directories for Airflow:

```bash
mkdir -p ./dags ./logs ./plugins ./config ./clickhouse_dbt
```

### 4. Configure Environment Variables

The `.env` file contains important configuration. Review and update if needed:

```bash
# Default credentials (CHANGE IN PRODUCTION!)
AIRFLOW_WWW_USER_USERNAME=airflow
AIRFLOW_WWW_USER_PASSWORD=airflow

# Generate secure keys for production:
# AIRFLOW_JWT_SECRET=<your-secure-jwt-secret>
# AIRFLOW_API_SECRET_KEY=<your-secure-api-secret>
```

**Important for Linux users**: Set the correct AIRFLOW_UID:

```bash
echo "AIRFLOW_UID=$(id -u)" >> .env
```

### 5. Build the Docker Images

Build the custom Airflow image with all dependencies:

```bash
docker compose build
```

This will:
- Use Apache Airflow 3.1.2 with Python 3.12
- Install additional tools (vim, wget, gnupg2)
- Install Python dependencies from `config/requirements.txt`

### 6. Start Airflow Services

Launch all Airflow services in detached mode:

```bash
docker compose up -d
```

This will start the following services:
- **postgres**: PostgreSQL database for Airflow metadata
- **redis**: Message broker for Celery
- **airflow-apiserver**: Airflow API server (accessible on port 8080)
- **airflow-scheduler**: Schedules DAG runs
- **airflow-dag-processor**: Processes DAG files
- **airflow-worker**: Executes tasks using Celery
- **airflow-triggerer**: Handles deferred tasks

### 7. Wait for Initialization

The first startup will take a few minutes as Airflow initializes the database and creates the admin user. Monitor the logs:

```bash
docker compose logs -f airflow-init
```

Wait until you see "airflow-init exited with code 0" or similar completion message.

## Accessing Airflow

Once all services are running:

1. Open your browser and navigate to: `http://localhost:8080`
2. Login with the credentials from your `.env` file:
   - Username: `airflow` (default)
   - Password: `airflow` (default)

## Verifying Installation

Check that all services are running:

```bash
docker compose ps
```

All services should show status as "healthy" or "running".

View logs for any service:

```bash
docker compose logs <service-name>
# Example:
docker compose logs airflow-scheduler
```

## Managing Airflow

### Stop Airflow

```bash
docker compose down
```

### Stop and Remove Volumes (Clean Reset)

```bash
docker compose down -v
```

**Warning**: This will delete all data including DAG runs, logs, and connections!

### Restart a Specific Service

```bash
docker compose restart airflow-scheduler
```

### View Running Services

```bash
docker compose ps
```

## Optional Services

### Flower (Celery Monitoring)

To enable the Flower web interface for monitoring Celery workers:

```bash
docker compose --profile flower up -d
```

Access Flower at: `http://localhost:5555`

## Troubleshooting

### Permission Issues (Linux)

If you encounter permission errors, ensure `AIRFLOW_UID` is set correctly:

```bash
echo "AIRFLOW_UID=$(id -u)" >> .env
docker compose down
docker compose up -d
```

### Services Not Starting

Check service logs:

```bash
docker compose logs <service-name>
```

### Database Connection Issues

Ensure PostgreSQL is healthy:

```bash
docker compose ps postgres
```

### Reset Everything

If you need a fresh start:

```bash
docker compose down -v
rm -rf logs/*
docker compose up -d
```

## Additional Configuration

### Adding Python Dependencies

1. Add packages to `config/requirements.txt`
2. Rebuild the image:
   ```bash
   docker compose build
   docker compose up -d
   ```

### Adding DAGs

Place your DAG files in the `./dags` directory. They will be automatically picked up by Airflow.

### Environment Variables

Key configuration can be modified in the `.env` file or `docker-compose.yaml`:

- Database connection
- Celery settings
- Worker concurrency
- DAG processing intervals

## Security Notes

**IMPORTANT**: The default configuration uses weak secrets suitable only for development!

For production deployments:

1. Generate strong secrets:
   ```bash
   # Generate a secure random key
   python3 -c "import secrets; print(secrets.token_urlsafe(32))"
   ```

2. Update `.env` with secure values:
   - `AIRFLOW_JWT_SECRET`
   - `AIRFLOW_API_SECRET_KEY`
   - `AIRFLOW_WWW_USER_PASSWORD`
   - `POSTGRES_PASSWORD`

3. Ensure `.env` is in `.gitignore` (it already is)

## Architecture

This setup uses:
- **Executor**: CeleryExecutor (for distributed task execution)
- **Database**: PostgreSQL 16
- **Message Broker**: Redis 7.2
- **Airflow Version**: 3.1.2
- **Python Version**: 3.12

## Support

For issues or questions:
- Check the [Apache Airflow documentation](https://airflow.apache.org/docs/)
- Review service logs: `docker compose logs <service-name>`
- Ensure system resources meet minimum requirements
