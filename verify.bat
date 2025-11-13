@echo off
REM Verification script for Motilal Project
echo ============================================
echo Motilal Project - Service Verification
echo ============================================
echo.

echo 1. Checking Docker...
docker --version
if errorlevel 1 (
    echo Docker not found
    exit /b 1
)

echo.
echo 2. Checking container status...
docker-compose ps

echo.
echo 3. Testing API endpoint...
echo Testing: http://localhost:8080/users/q2j9acdC
curl.exe -s http://localhost:8080/users/q2j9acdC
echo.

echo.
echo 4. Services are available at:
echo    API:        http://localhost:8080
echo    Kafka:      localhost:9092
echo    SQL Server: localhost:1433
echo    Redis:      localhost:6380
echo.

echo Verification complete!
echo To view logs: docker-compose logs -f [service-name]
