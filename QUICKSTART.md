# Motilal Project - Quick Start Guide

## ✅ Project Status: FULLY OPERATIONAL

All services are running and responding correctly.

## 🚀 Start the Project

```bash
cd d:\motilal_project
docker-compose up -d
```

Wait 8-10 seconds for all services to initialize.

## 📋 Verify Everything is Working

```bash
.\verify.bat
```

Expected output:
- All 7 containers should show `Up` status
- API endpoint should return user data
- Services should be accessible on their respective ports

## 🧪 Test the API

### Get User with Orders
```bash
curl.exe http://localhost:8080/users/q2j9acdC
```

Sample user IDs from the producer:
- q2j9acdC
- fYEl4Zcj
- sOyCBE5x
- mpF9eIIY
- Q4WTIEo6

### Get Order Details
```bash
curl.exe http://localhost:8080/orders/yFKd1oH0
```

Sample order IDs:
- yFKd1oH0
- NBH9wAvr
- 2YXnhiR9
- 5HhV8qdp

## 📊 System Architecture

```
Producer (generates events)
        ↓
    Kafka (events broker)
        ↓
Consumer (processes events)
        ↓
    MS SQL (data storage)
        ↓
    API (query interface)
        ↓
   Client (your requests)
```

## 🔧 Key Services

| Service | Purpose | Port | Status |
|---------|---------|------|--------|
| **Zookeeper** | Kafka coordination | 2181 | ✓ Running |
| **Kafka** | Event streaming | 9092 | ✓ Running |
| **MS SQL Server** | Data persistence | 1433 | ✓ Running |
| **Redis** | Error Dead Letter Queue | 6380 | ✓ Running |
| **Producer** | Event generation | - | ✓ Running |
| **Consumer** | Event processing | - | ✓ Running |
| **API** | REST interface | 8080 | ✓ Running |

## 📥 Database Schema

```sql
-- Users
CREATE TABLE users (
    id VARCHAR(64) PRIMARY KEY,
    name VARCHAR(128),
    email VARCHAR(128),
    created_at DATETIME
);

-- Orders
CREATE TABLE orders (
    id VARCHAR(64) PRIMARY KEY,
    user_id VARCHAR(64),
    amount DECIMAL(18,2),
    status VARCHAR(32),
    created_at DATETIME
);

-- Payments
CREATE TABLE payments (
    id VARCHAR(64) PRIMARY KEY,
    order_id VARCHAR(64),
    status VARCHAR(32),
    settled_at DATETIME
);

-- Inventory
CREATE TABLE inventory (
    sku VARCHAR(64) PRIMARY KEY,
    quantity INT,
    adjusted_at DATETIME
);
```

## 🎯 Data Flow

1. **Producer generates 4 types of events:**
   - UserCreated (every 1-2 seconds)
   - OrderPlaced (for random users)
   - PaymentSettled (for random orders)
   - InventoryAdjusted (random inventory items)

2. **Events are published to Kafka topic: `events`**

3. **Consumer subscribes to events:**
   - Upserts user data to `users` table
   - Inserts order data to `orders` table
   - Inserts payment data to `payments` table
   - Inserts inventory data to `inventory` table
   - On errors: retries 3 times, then pushes to Redis DLQ

4. **API queries the database:**
   - GET /users/{id} → retrieves user + last 5 orders
   - GET /orders/{id} → retrieves order + payment status

## 🛑 Stop the Project

```bash
docker-compose down
```

To remove all data (fresh restart):
```bash
docker-compose down -v
docker-compose up -d
```

## 📋 Troubleshooting

### Services not responding
```bash
docker-compose restart
```

### View service logs
```bash
docker-compose logs -f consumer     # View consumer logs
docker-compose logs -f producer     # View producer logs
docker-compose logs -f api          # View API logs
docker-compose logs -f kafka        # View Kafka logs
```

### Check database connection
```bash
docker-compose exec mssql /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "YourStrong!Passw0rd" -Q "SELECT COUNT(*) FROM eventdb.dbo.users"
```

### Check Kafka topics
```bash
docker-compose exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

## 📝 API Response Examples

### User with Orders Response
```json
{
  "id": "q2j9acdC",
  "name": "Dave",
  "email": "Alice@example.com",
  "createdAt": "2025-11-11T11:47:27.163Z",
  "orders": [
    {
      "id": "yFKd1oH0",
      "userId": "q2j9acdC",
      "amount": 456.78,
      "status": "pending",
      "createdAt": "2025-11-11T11:47:34.921Z",
      "payment": null
    }
  ]
}
```

## 🔐 Credentials

- **Database User**: SA
- **Database Password**: YourStrong!Passw0rd
- **Database Name**: eventdb
- **SQL Server Port**: 1433

## 📚 Additional Resources

- Complete setup documentation: See `SETUP.md`
- Sample API requests: See `sample.http`
- Database schema: See `schema.sql`
- Docker Compose config: See `docker-compose.yml`

## ✨ Everything is Ready!

Your project is fully functional and ready to use. All services are running, the API is responding, and data is flowing through the system.

Start using the API with the endpoints listed above!
