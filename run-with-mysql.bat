@echo off
REM =====================================================
REM XP Application - MySQL Setup Script (Windows)
REM Description: Script to run XP Application with MySQL database
REM Author: XP Development Team
REM Date: 2024-01-15
REM =====================================================

echo 🚀 Starting XP Application with MySQL...

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not running. Please start Docker first.
    pause
    exit /b 1
)

REM Check if MySQL container is running
docker ps | findstr "xp-mysql" >nul
if %errorlevel% neq 0 (
    echo [INFO] Starting MySQL container...
    docker-compose -f docker-compose-mysql.yml up -d mysql
    
    REM Wait for MySQL to be ready
    echo [INFO] Waiting for MySQL to be ready...
    timeout /t 30 /nobreak >nul
    
    REM Check if MySQL is ready
    docker exec xp-mysql mysqladmin ping -h localhost --silent >nul
    if %errorlevel% neq 0 (
        echo [ERROR] MySQL is not ready. Please check the container logs.
        pause
        exit /b 1
    )
    
    echo [SUCCESS] MySQL container is running!
) else (
    echo [SUCCESS] MySQL container is already running!
)

REM Check if phpMyAdmin container is running
docker ps | findstr "xp-phpmyadmin" >nul
if %errorlevel% neq 0 (
    echo [INFO] Starting phpMyAdmin container...
    docker-compose -f docker-compose-mysql.yml up -d phpmyadmin
    echo [SUCCESS] phpMyAdmin is available at http://localhost:8081
) else (
    echo [SUCCESS] phpMyAdmin is already running at http://localhost:8081
)

REM Display connection information
echo.
echo [INFO] Database Connection Information:
echo   Host: localhost
echo   Port: 3306
echo   Database: xpdb
echo   Username: xp_user
echo   Password: xp_password
echo.
echo [INFO] phpMyAdmin: http://localhost:8081
echo   Username: xp_user
echo   Password: xp_password
echo.

REM Ask user which profile to run
echo Select the profile to run:
echo 1) MySQL Development (application-mysql.properties)
echo 2) MySQL Production (application-prod.properties)
echo 3) H2 Development (application.properties) - Default
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" (
    set PROFILE=mysql
    echo [INFO] Running with MySQL Development profile...
) else if "%choice%"=="2" (
    set PROFILE=prod
    echo [INFO] Running with MySQL Production profile...
) else if "%choice%"=="3" (
    set PROFILE=
    echo [INFO] Running with H2 Development profile (default)...
) else (
    echo [ERROR] Invalid choice. Running with default H2 profile...
    set PROFILE=
)

REM Run the application
if defined PROFILE (
    echo [INFO] Starting XP Application with profile: %PROFILE%
    mvnw.cmd spring-boot:run -Dspring-boot.run.profiles=%PROFILE%
) else (
    echo [INFO] Starting XP Application with default profile
    mvnw.cmd spring-boot:run
)

echo [SUCCESS] XP Application started successfully!
echo.
echo [INFO] Application URLs:
echo   Application: https://localhost:8080
echo   Swagger UI: https://localhost:8080/swagger-ui.html
echo   Health Check: https://localhost:8080/actuator/health
echo   ESB Info: https://localhost:8080/api/esb/info
echo.
echo [INFO] To stop the application, press Ctrl+C
echo [INFO] To stop MySQL containers, run: docker-compose -f docker-compose-mysql.yml down
pause
