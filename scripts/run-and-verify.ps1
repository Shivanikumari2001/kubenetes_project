# Complete Project Runner and Verification Script
# This script starts all services and verifies everything is running

Write-Host "🚀 Starting Microservices Project..." -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# Colors
$GREEN = "Green"
$RED = "Red"
$YELLOW = "Yellow"
$BLUE = "Blue"

# Function to check if port is in use
function Test-Port {
    param($Port)
    try {
        $connection = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        return $null -ne $connection
    } catch {
        return $false
    }
}

# Function to test HTTP endpoint
function Test-HttpEndpoint {
    param($Url, $Name)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✓ $Name is responding (Status: $($response.StatusCode))" -ForegroundColor $GREEN
        return $true
    }
    catch {
        Write-Host "✗ $Name is NOT responding: $_" -ForegroundColor $RED
        return $false
    }
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "1️⃣  Checking Prerequisites" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check if services are already running
$port3000 = Test-Port 3000
$port3001 = Test-Port 3001
$port3002 = Test-Port 3002

if ($port3000 -or $port3001 -or $port3002) {
    Write-Host "⚠ Some services may already be running on ports 3000, 3001, or 3002" -ForegroundColor $YELLOW
    Write-Host ""
    Write-Host "Port 3000 (API Gateway): $(if($port3000){'IN USE'}else{'FREE'})" -ForegroundColor $(if($port3000){$YELLOW}else{$GREEN})
    Write-Host "Port 3001 (Service1):    $(if($port3001){'IN USE'}else{'FREE'})" -ForegroundColor $(if($port3001){$YELLOW}else{$GREEN})
    Write-Host "Port 3002 (Service2):    $(if($port3002){'IN USE'}else{'FREE'})" -ForegroundColor $(if($port3002){$YELLOW}else{$GREEN})
    Write-Host ""
    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "Exiting..." -ForegroundColor $YELLOW
        exit 0
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "2️⃣  Checking Dependencies" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$rootDir = Split-Path -Parent $PSScriptRoot

# Check if node_modules exist
$services = @("service1", "service2", "api-gateway")
foreach ($service in $services) {
    $nodeModulesPath = Join-Path $rootDir $service "node_modules"
    if (Test-Path $nodeModulesPath) {
        Write-Host "✓ $service dependencies installed" -ForegroundColor $GREEN
    } else {
        Write-Host "✗ $service dependencies NOT installed" -ForegroundColor $RED
        Write-Host "  Run: cd $service && npm install" -ForegroundColor $YELLOW
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "3️⃣  Starting Services" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check for existing jobs
$existingJobs = Get-Job -ErrorAction SilentlyContinue | Where-Object { $_.Name -in @("Service1", "Service2", "APIGateway") }
if ($existingJobs) {
    Write-Host "⚠ Found existing background jobs. Stopping them..." -ForegroundColor $YELLOW
    $existingJobs | Stop-Job
    $existingJobs | Remove-Job
}

# Start Service1
Write-Host "Starting Service1..." -ForegroundColor $BLUE
$service1Path = Join-Path $rootDir "service1"
$job1 = Start-Job -Name "Service1" -ScriptBlock { 
    Set-Location $using:service1Path
    npm run start:dev 2>&1
}

# Start Service2
Write-Host "Starting Service2..." -ForegroundColor $BLUE
$service2Path = Join-Path $rootDir "service2"
$job2 = Start-Job -Name "Service2" -ScriptBlock { 
    Set-Location $using:service2Path
    npm run start:dev 2>&1
}

# Start API Gateway
Write-Host "Starting API Gateway..." -ForegroundColor $BLUE
$gatewayPath = Join-Path $rootDir "api-gateway"
$job3 = Start-Job -Name "APIGateway" -ScriptBlock { 
    Set-Location $using:gatewayPath
    npm run start:dev 2>&1
}

Write-Host "Waiting for services to start (30 seconds)..." -ForegroundColor $YELLOW
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "4️⃣  Checking Service Logs" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "Service1 Logs:" -ForegroundColor $BLUE
$job1Logs = Receive-Job -Name Service1 -Keep | Select-Object -Last 10
$job1Logs | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "Service2 Logs:" -ForegroundColor $BLUE
$job2Logs = Receive-Job -Name Service2 -Keep | Select-Object -Last 10
$job2Logs | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "API Gateway Logs:" -ForegroundColor $BLUE
$job3Logs = Receive-Job -Name APIGateway -Keep | Select-Object -Last 10
$job3Logs | ForEach-Object { Write-Host "  $_" }

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "5️⃣  Testing Service Endpoints" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$results = @{}

# Test Service2
$results["Service2"] = Test-HttpEndpoint "http://localhost:3002/health" "Service2 (port 3002)"

# Test Service1
$results["Service1"] = Test-HttpEndpoint "http://localhost:3001/health" "Service1 (port 3001)"

# Test API Gateway
$results["API Gateway"] = Test-HttpEndpoint "http://localhost:3000/health" "API Gateway (port 3000)"

# Test API Gateway root
$results["API Gateway Root"] = Test-HttpEndpoint "http://localhost:3000/" "API Gateway Root"

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "6️⃣  Testing API Gateway Routing" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

if ($results["Service1"] -and $results["Service2"]) {
    # Test routing through API Gateway
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/users" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✓ API Gateway routing to Service1 works" -ForegroundColor $GREEN
        $results["Gateway->Service1"] = $true
    } catch {
        Write-Host "✗ API Gateway routing to Service1 failed: $_" -ForegroundColor $RED
        $results["Gateway->Service1"] = $false
    }
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/payments" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✓ API Gateway routing to Service2 works" -ForegroundColor $GREEN
        $results["Gateway->Service2"] = $true
    } catch {
        Write-Host "✗ API Gateway routing to Service2 failed: $_" -ForegroundColor $RED
        $results["Gateway->Service2"] = $false
    }
} else {
    Write-Host "⚠ Skipping routing tests (services not ready)" -ForegroundColor $YELLOW
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$passed = ($results.Values | Where-Object { $_ -eq $true }).Count
$failed = ($results.Values | Where-Object { $_ -eq $false }).Count

Write-Host "Total Tests: $($results.Count)" -ForegroundColor White
Write-Host "✓ Passed: $passed" -ForegroundColor $GREEN
Write-Host "✗ Failed: $failed" -ForegroundColor $(if($failed -gt 0){$RED}else{$GREEN})

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📋 Background Jobs Status" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Get-Job | Where-Object { $_.Name -in @("Service1", "Service2", "APIGateway") } | Format-Table Id, Name, State, HasMoreData

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🔗 Access URLs" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "API Gateway:     http://localhost:3000" -ForegroundColor $BLUE
Write-Host "API Gateway:     http://localhost:3000/health" -ForegroundColor $BLUE
Write-Host "Service1:        http://localhost:3001/health" -ForegroundColor $BLUE
Write-Host "Service2:        http://localhost:3002/health" -ForegroundColor $BLUE
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🛠️  Management Commands" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "View logs:       Receive-Job -Name Service1 -Keep" -ForegroundColor $YELLOW
Write-Host "Stop service:    Stop-Job -Name Service1; Remove-Job -Name Service1" -ForegroundColor $YELLOW
Write-Host "List jobs:       Get-Job" -ForegroundColor $YELLOW
Write-Host ""

if ($failed -eq 0) {
    Write-Host "🎉 All services are running successfully!" -ForegroundColor $GREEN
    exit 0
} else {
    Write-Host "⚠ Some services failed. Check logs above for details." -ForegroundColor $YELLOW
    exit 1
}

