@echo off
REM XP Application Performance Test Script
REM Executes JMeter performance tests and generates reports

echo ========================================
echo XP Application Performance Test Suite
echo ========================================

REM Check if JMeter is installed
where jmeter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: JMeter not found in PATH
    echo Please install JMeter and add it to your PATH
    echo Download from: https://jmeter.apache.org/download_jmeter.cgi
    pause
    exit /b 1
)

REM Create results directory
if not exist "results" mkdir results
if not exist "reports" mkdir reports

echo.
echo Starting XP Application...
echo Please ensure the application is running on http://localhost:8080
echo.
pause

REM Run the performance test
echo Running performance tests...
jmeter -n -t performance-tests\XP-Application-Performance-Test.jmx -l results\performance-test-results.jtl -e -o reports\html-report

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Performance test completed successfully!
    echo ========================================
    echo.
    echo Results saved to:
    echo - Raw results: results\performance-test-results.jtl
    echo - HTML Report: reports\html-report\index.html
    echo.
    echo Opening HTML report...
    start reports\html-report\index.html
) else (
    echo.
    echo ERROR: Performance test failed!
    echo Please check the application is running and try again.
)

pause
