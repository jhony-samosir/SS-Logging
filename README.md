# SS-Logging

## Overview

SS-Logging is the centralized observability and telemetry infrastructure project for the SamStore microservices ecosystem. It provides the necessary configurations and pipeline setups to aggregate logs, collect metric gauges, and visualize distributed traces across all application microservices.

Rather than relying on direct service-to-service diagnostic endpoints, it sets up robust collector pipelines using OpenTelemetry, Fluent Bit, Grafana, Loki, and Tempo to establish comprehensive tracing and debugging dashboards.

## Features

- **Centralized Log Processing**: Employs Fluent Bit to ingest, parse, and forward containerized stdout/stderr logs directly into Loki.
- **Distributed Tracing**: Integrates Tempo as a trace storage engine to query downstream microservice transaction spans.
- **OpenTelemetry Collector Pipeline**: Sets up a unified receiver forwarding traces to Tempo, logs to Loki, and debugging metrics outputs.
- **Correlated Dashboards**: Includes pre-configured Grafana dashboards connecting trace spans to log statements automatically.

## Tech Stack

| Category       | Technology              |
| -------------- | ----------------------- |
| Log Forwarding | Fluent Bit              |
| Log Storage    | Grafana Loki            |
| Trace Storage  | Grafana Tempo           |
| Ingestion      | OpenTelemetry Collector |
| Visualization  | Grafana                 |

## Project Structure

```text
SS-Logging/
├── grafana/
│   ├── dashboards/            # Pre-configured dashboard json setups (logs & traces)
│   └── datasources/           # Provisioned datasource properties linking Loki/Tempo
├── fluent-bit.conf            # Core Fluent Bit routing configuration
├── loki-config.yaml           # Grafana Loki index and retention parameters
├── otel-collector-config.yaml # OpenTelemetry trace/log collector routing
├── parsers.conf               # Log parser formatting rules (e.g. docker_json)
└── tempo-config.yaml          # Tempo traces memory and storage options
```

## Requirements

- Docker and Docker Compose
- OpenTelemetry-supported microservices

## Installation

```bash
git clone <repository>
cd SamStore/SS-Logging
```

## Configuration

The configuration parameters are managed inside the YAML properties. Key communication ports:

- **Fluent Bit Ingestion**: `24224` (Forward Protocol)
- **OTel Collector Receivers**: `4317` (OTLP gRPC), `4318` (OTLP HTTP)
- **Loki Endpoint**: `3100` (HTTP)
- **Tempo Endpoint**: `3200` (HTTP)
- **Grafana Dashboard Port**: `3000` (Web UI)

## Running Locally

To orchestrate the observability stack locally, mount the configuration files inside a Docker Compose network configuration:

```bash
# Recommended deployment via Docker Compose
docker compose up -d
```

## Build

Not identified from source code. (Configuration files, no compiled source).

## Testing

Not identified from source code.

## API Documentation

Not identified from source code.

## Database

Not identified from source code (Utilizes file system storage `/tmp/` directories for development indexing by Loki and Tempo).

## Deployment

- **Docker**: Component applications (OTel, Fluent Bit, Loki, Tempo, Grafana) run as standard Docker containers.
- **Docker Compose**: Orchestration configurations link memory boundaries on a mutual docker virtual network.

## Architecture Notes

- **Telemetry Pipeline Pattern**: Microservice -> OpenTelemetry SDK -> OTel Collector -> Tempo (Traces) & Loki (Logs via Fluent Bit) -> Grafana.
- **Correlation Design**: Ensures trace-to-log navigation links using shared JSON log parameters (`traceId` / `trace_id`).

## Known Issues

- Storage paths default to `/tmp/...`. Production deployments must mount persistent block volumes.

## Future Improvements

- Integrate Prometheus metric visualization dashboards.

## License

```text
License information not specified.
```
