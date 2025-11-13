@echo off
REM Motilal Project - Helper Menu
REM Quick access to common operations

:menu
cls
echo.
echo ============================================
echo    MOTILAL PROJECT - COMMAND HELPER
echo ============================================
echo.
echo 1. Start all services
echo 2. Stop all services
echo 3. Verify all services are running
echo 4. View API logs (real-time)
echo 5. View Producer logs (real-time)
echo 6. View Consumer logs (real-time)
echo 7. View Kafka logs (real-time)
echo 8. Test API endpoint - Get User
echo 9. Check container status
echo 10. Restart all services
echo 11. Full reset (remove all data)
echo 12. Exit
echo.
set /p choice=Enter your choice (1-12): 

if "%choice%"=="1" goto start
if "%choice%"=="2" goto stop
if "%choice%"=="3" goto verify
if "%choice%"=="4" goto logs_api
if "%choice%"=="5" goto logs_producer
if "%choice%"=="6" goto logs_consumer
if "%choice%"=="7" goto logs_kafka
if "%choice%"=="8" goto test_api
if "%choice%"=="9" goto status
if "%choice%"=="10" goto restart
if "%choice%"=="11" goto reset
if "%choice%"=="12" goto exit

echo Invalid choice. Please try again.
timeout /t 2
goto menu

:start
echo.
echo Starting all services...
docker-compose up -d
echo.
echo Services started. Waiting for initialization...
timeout /t 5
echo Done! Services are starting up.
pause
goto menu

:stop
echo.
echo Stopping all services...
docker-compose down
echo.
echo Services stopped.
pause
goto menu

:verify
echo.
echo Verifying services...
call verify.bat
pause
goto menu

:logs_api
echo.
echo Showing API logs (Ctrl+C to exit)...
docker-compose logs -f api
goto menu

:logs_producer
echo.
echo Showing Producer logs (Ctrl+C to exit)...
docker-compose logs -f producer
goto menu

:logs_consumer
echo.
echo Showing Consumer logs (Ctrl+C to exit)...
docker-compose logs -f consumer
goto menu

:logs_kafka
echo.
echo Showing Kafka logs (Ctrl+C to exit)...
docker-compose logs -f kafka
goto menu

:test_api
echo.
echo Testing API endpoint...
echo.
set /p userid=Enter user ID (or press Enter for default q2j9acdC): 
if "%userid%"=="" set userid=q2j9acdC
echo.
echo Testing: http://localhost:8080/users/%userid%
echo.
curl.exe -s http://localhost:8080/users/%userid%
echo.
echo.
pause
goto menu

:status
echo.
echo Container Status:
echo.
docker-compose ps
echo.
pause
goto menu

:restart
echo.
echo Restarting all services...
docker-compose restart
echo.
echo Services restarted. Waiting for initialization...
timeout /t 5
echo Done!
pause
goto menu

:reset
echo.
echo WARNING: This will remove all data and start fresh!
set /p confirm=Are you sure? (yes/no): 
if /i "%confirm%"=="yes" (
    echo.
    echo Performing full reset...
    docker-compose down -v
    echo.
    echo Starting fresh...
    docker-compose up -d
    echo.
    echo Reset complete. Services are starting up...
    timeout /t 5
) else (
    echo Reset cancelled.
)
pause
goto menu

:exit
echo.
echo Goodbye!
echo.
exit /b 0
