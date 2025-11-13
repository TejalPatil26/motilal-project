# Motilal Project - Complete Setup Guide

## Project Overview
A Kafka-based event pipeline demo with:
- **Producer**: Generates 4 event types (UserCreated, OrderPlaced, PaymentSettled, InventoryAdjusted)
- **Consumer**: Consumes events and stores them in MS SQL Server
- **API**: REST API to query users and orders
- **Infrastructure**: Kafka, Zookeeper, MS SQL Server, Redis (DLQ)

## Prerequisites
- Docker & Docker Compose installed
- 4GB+ RAM available
- Windows PowerShell or similar terminal

## Quick Start

### 1. Start the Project
```bash
cd d:\motilal_project
docker-compose up -d
```

### 2. Wait for Services to Initialize
Services typically take 8-10 seconds to fully initialize. Check status:
```bash
docker-compose ps
```

### 3. Test the API

Get user with orders:
```bash
curl.exe http://localhost:8080/users/q2j9acdC
```

Get order details:
```bash
curl.exe http://localhost:8080/orders/yFKd1oH0
```

## Service Details

| Service | Port | Status |
|---------|------|--------|
| API | 8080 | Ready |
| Kafka | 9092 | Ready |
| Zookeeper | 2181 | Ready |
| MS SQL | 1433 | Ready |
| Redis | 6380 | Ready |

### Database Connection
- **Server**: localhost:1433
- **User**: SA
- **Password**: YourStrong!Passw0rd
- **Database**: eventdb

### Database Tables
- `users` - User records
- `orders` - Order records
- `payments` - Payment records
- `inventory` - Inventory records

## API Endpoints

### GET /users/{id}
Returns user information with last 5 orders.

**Example:**
```bash
curl.exe http://localhost:8080/users/q2j9acdC
```

**Response:**
```json
{
  "id": "q2j9acdC",
  "name": "Dave",
  "email": "Alice@example.com",
  "createdAt": "2025-11-11T11:47:27.163Z",
  "orders": [...]
}
```

### GET /orders/{id}
Returns order information with payment status.

**Example:**
```bash
curl.exe http://localhost:8080/orders/yFKd1oH0
```

## Data Flow

1. **Producer** generates events to Kafka (UserCreated, OrderPlaced, PaymentSettled, InventoryAdjusted)
2. **Consumer** reads from Kafka and processes events:
   - Inserts users, orders, payments, inventory into MS SQL
   - On error: retries up to 3 times, then pushes to Redis DLQ
3. **API** queries MS SQL and returns formatted responses

## Troubleshooting

### Services not starting
```bash
docker-compose down
docker-compose up -d
```

### Check service logs
```bash
docker-compose logs -f [service-name]
# e.g., docker-compose logs -f consumer
```

### Reset everything
```bash
docker-compose down -v  # -v removes volumes
docker-compose up -d
```

### Check database connection
```bash
docker exec motilal_project-mssql-1 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "YourStrong!Passw0rd" -Q "SELECT @@VERSION"
```

## Environment Variables

### Consumer
- `KAFKA_BROKER`: kafka:9092
- `KAFKA_TOPIC`: events
- `KAFKA_GROUP_ID`: event-consumer-group
- `SQL_SERVER_DSN`: sqlserver://SA:YourStrong!Passw0rd@mssql:1433?database=eventdb
- `REDIS_ADDR`: redis:6379

### API
- `SQLSERVER_CONN`: sqlserver://SA:YourStrong!Passw0rd@mssql:1433?database=eventdb

### Producer
- `KAFKA_BROKER`: kafka:9092

## Files Structure

```
.
├── docker-compose.yml      # Orchestration configuration
├── README.md               # Project description
├── SETUP.md               # This file
├── schema.sql             # Database schema
├── sample.http            # Sample API requests
├── api/                   # REST API service
│   ├── main.go
│   ├── Dockerfile
│   └── go.mod
├── producer/              # Event producer service
│   ├── main.go
│   ├── Dockerfile
│   └── go.mod
├── consumer/              # Event consumer service
│   ├── main.go
│   ├── Dockerfile
│   └── go.mod
└── mssql-init/            # Database initialization
    └── init.sql
```

## Stopping the Project

```bash
docker-compose down
```

To remove all data:
```bash
docker-compose down -v
```

## Success Indicators

✅ All containers are running
✅ API responds on http://localhost:8080
✅ Producer generates events continuously
✅ Consumer processes events without errors
✅ Database has user and order records

## Additional Resources

- Kafka Documentation: https://kafka.apache.org/
- Go Documentation: https://golang.org/doc/
- Docker Documentation: https://docs.docker.com/
