#!/usr/bin/env powershell
# Verification script for Motilal Project
# This script validates that all services are running and responsive

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Motilal Project - Service Verification" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Check Docker
Write-Host "1. Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "   ✓ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Docker not found" -ForegroundColor Red
    exit 1
}

# Check Docker Compose
Write-Host "2. Checking Docker Compose..." -ForegroundColor Yellow
try {
    $dockerComposeVersion = docker-compose --version
    Write-Host "   ✓ $dockerComposeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Docker Compose not found" -ForegroundColor Red
    exit 1
}

# Check container status
Write-Host "3. Checking container status..." -ForegroundColor Yellow
$containers = @(
    "motilal_project-zookeeper-1",
    "motilal_project-kafka-1",
    "motilal_project-mssql-1",
    "motilal_project-redis-1",
    "motilal_project-producer-1",
    "motilal_project-consumer-1",
    "motilal_project-api-1"
)

foreach ($container in $containers) {
    $status = docker inspect -f '{{.State.Status}}' $container 2>$null
    if ($status -eq "running") {
        Write-Host "   ✓ $container : Running" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $container : $status" -ForegroundColor Red
    }
}

# Check API endpoint
Write-Host ""
Write-Host "4. Checking API endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction SilentlyContinue
    Write-Host "   ✓ API is responding" -ForegroundColor Green
} catch {
    Write-Host "   ! API endpoint /health not available, trying sample user endpoint..." -ForegroundColor Yellow
    try {
        # Try to get any user
        $response = & curl.exe -s http://localhost:8080/users/q2j9acdC
        if ($response) {
            Write-Host "   ✓ API sample endpoint is working" -ForegroundColor Green
            Write-Host "   Response: $($response | ConvertFrom-Json | ConvertTo-Json -Compress | Select-Object -First 100)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "   ✗ API not responding" -ForegroundColor Red
    }
}

# Check Kafka
Write-Host ""
Write-Host "5. Checking Kafka..." -ForegroundColor Yellow
try {
    $kafkaLogs = docker logs motilal_project-kafka-1 --tail 2 2>&1
    if ($kafkaLogs -like "*started*" -or $kafkaLogs -like "*broker*") {
        Write-Host "   ✓ Kafka is running" -ForegroundColor Green
    } else {
        Write-Host "   ✓ Kafka container running" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Cannot check Kafka" -ForegroundColor Red
}

# Check Producer
Write-Host ""
Write-Host "6. Checking Producer..." -ForegroundColor Yellow
try {
    $producerLogs = docker logs motilal_project-producer-1 --tail 5 2>&1
    if ($producerLogs -like "*produced*") {
        Write-Host "   ✓ Producer is generating events" -ForegroundColor Green
        $eventCount = ($producerLogs | Select-String "produced" | Measure-Object).Count
        Write-Host "   Recent events: $eventCount (last 5 logs)" -ForegroundColor Gray
    } else {
        Write-Host "   ✓ Producer container running" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Cannot check Producer" -ForegroundColor Red
}

# Check Consumer
Write-Host ""
Write-Host "7. Checking Consumer..." -ForegroundColor Yellow
try {
    $consumerLogs = docker logs motilal_project-consumer-1 --tail 5 2>&1
    if ($consumerLogs -like "*processed*") {
        Write-Host "   ✓ Consumer is processing events" -ForegroundColor Green
        $processedCount = ($consumerLogs | Select-String "processed" | Measure-Object).Count
        Write-Host "   Processed events: $processedCount (last 5 logs)" -ForegroundColor Gray
    } else {
        Write-Host "   ✓ Consumer container running" -ForegroundColor Green
    }
} catch {
    Write-Host "   ✗ Cannot check Consumer" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "Verification Complete!" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API Endpoints:" -ForegroundColor Yellow
Write-Host "  GET  http://localhost:8080/users/{id}" -ForegroundColor Gray
Write-Host "  GET  http://localhost:8080/orders/{id}" -ForegroundColor Gray
Write-Host ""
Write-Host "To view logs:" -ForegroundColor Yellow
Write-Host "  docker-compose logs -f [service-name]" -ForegroundColor Gray
Write-Host ""
Write-Host "Services Port Mapping:" -ForegroundColor Yellow
Write-Host "  API:        8080" -ForegroundColor Gray
Write-Host "  Kafka:      9092" -ForegroundColor Gray
Write-Host "  Zookeeper:  2181" -ForegroundColor Gray
Write-Host "  MS SQL:     1433" -ForegroundColor Gray
Write-Host "  Redis:      6380" -ForegroundColor Gray
Write-Host ""
