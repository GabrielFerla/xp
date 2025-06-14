#!/bin/bash
# XP Application Performance Test Script (Linux/Mac)
# Executes JMeter performance tests and generates reports

echo "========================================"
echo "XP Application Performance Test Suite"
echo "========================================"

# Check if JMeter is installed
if ! command -v jmeter &> /dev/null; then
    echo "ERROR: JMeter not found in PATH"
    echo "Please install JMeter and add it to your PATH"
    echo "Download from: https://jmeter.apache.org/download_jmeter.cgi"
    exit 1
fi

# Create results directory
mkdir -p results
mkdir -p reports

echo ""
echo "Starting XP Application..."
echo "Please ensure the application is running on http://localhost:8080"
echo ""
read -p "Press Enter to continue..."

# Run the performance test
echo "Running performance tests..."
jmeter -n -t performance-tests/XP-Application-Performance-Test.jmx -l results/performance-test-results.jtl -e -o reports/html-report

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Performance test completed successfully!"
    echo "========================================"
    echo ""
    echo "Results saved to:"
    echo "- Raw results: results/performance-test-results.jtl"
    echo "- HTML Report: reports/html-report/index.html"
    echo ""
    echo "Opening HTML report..."
    
    # Try to open the report based on OS
    if command -v xdg-open &> /dev/null; then
        xdg-open reports/html-report/index.html
    elif command -v open &> /dev/null; then
        open reports/html-report/index.html
    else
        echo "Please open reports/html-report/index.html manually"
    fi
else
    echo ""
    echo "ERROR: Performance test failed!"
    echo "Please check the application is running and try again."
fi
