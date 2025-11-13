@echo off
REM Script to find and test working user IDs

echo.
echo ========================================
echo   MOTILAL API - WORKING USER IDS
echo ========================================
echo.

echo Finding recent users created...
echo.

REM Get the first 5 created users from producer logs
for /f "delims= " %%a in ('docker-compose logs producer ^| findstr /R "produced UserCreated" ^| more +0') do (
    echo %%a
)

echo.
echo ========================================
echo   WORKING USER IDS (Tested):
echo ========================================
echo.

echo Testing known working users:
echo.

REM Test each user
call curl.exe -s http://localhost:8080/users/eWV43ZKL | findstr /C:"id" >nul && (
    echo [OK] eWV43ZKL - Use: curl.exe http://localhost:8080/users/eWV43ZKL
) || (
    echo [NEW] Generate fresh user by waiting for producer events
)

call curl.exe -s http://localhost:8080/users/3uYzNyvm | findstr /C:"id" >nul && (
    echo [OK] 3uYzNyvm - Use: curl.exe http://localhost:8080/users/3uYzNyvm
)

call curl.exe -s http://localhost:8080/users/9rnFGLjg | findstr /C:"id" >nul && (
    echo [OK] 9rnFGLjg - Use: curl.exe http://localhost:8080/users/9rnFGLjg
)

echo.
echo ========================================
echo   QUICK TEST:
echo ========================================
echo.
echo Running: curl.exe http://localhost:8080/users/eWV43ZKL
echo.
call curl.exe -s http://localhost:8080/users/eWV43ZKL
echo.
echo.
echo ========================================
echo   To find more user IDs:
echo ========================================
echo docker-compose logs producer ^| Select-String "UserCreated" ^| Select-Object -First 10
echo.
