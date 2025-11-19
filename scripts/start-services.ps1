# Quick Service Starter Script
# Starts all three microservices and verifies they're running

Write-Host "🚀 Starting All Microservices..." -ForegroundColor Cyan
Write-Host ""

$rootDir = Split-Path -Parent $PSScriptRoot

# Stop existing jobs
Get-Job | Where-Object { $_.Name -in @("Service1", "Service2", "APIGateway") } | Stop-Job -ErrorAction SilentlyContinue
Get-Job | Where-Object { $_.Name -in @("Service1", "Service2", "APIGateway") } | Remove-Job -ErrorAction SilentlyContinue

# Start Service1
Write-Host "Starting Service1..." -ForegroundColor Blue
Start-Job -Name "Service1" -ScriptBlock { 
    Set-Location E:\kube\service1
    npm run start:dev 2>&1
} | Out-Null

# Start Service2
Write-Host "Starting Service2..." -ForegroundColor Blue
Start-Job -Name "Service2" -ScriptBlock { 
    Set-Location E:\kube\service2
    npm run start:dev 2>&1
} | Out-Null

# Start API Gateway
Write-Host "Starting API Gateway..." -ForegroundColor Blue
Start-Job -Name "APIGateway" -ScriptBlock { 
    Set-Location E:\kube\api-gateway
    npm run start:dev 2>&1
} | Out-Null

Write-Host ""
Write-Host "Waiting for services to start (40 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 40

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Service Status:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check Service1
try {
    $r1 = Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Service1 (port 3001): RUNNING" -ForegroundColor Green
} catch {
    Write-Host "✗ Service1 (port 3001): NOT RUNNING" -ForegroundColor Red
}

# Check Service2
try {
    $r2 = Invoke-WebRequest -Uri "http://localhost:3002/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ Service2 (port 3002): RUNNING" -ForegroundColor Green
} catch {
    Write-Host "✗ Service2 (port 3002): NOT RUNNING" -ForegroundColor Red
}

# Check API Gateway
try {
    $r3 = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "✓ API Gateway (port 3000): RUNNING" -ForegroundColor Green
} catch {
    Write-Host "✗ API Gateway (port 3000): NOT RUNNING" -ForegroundColor Red
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Access URLs:" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "API Gateway: http://localhost:3000" -ForegroundColor Blue
Write-Host "Service1:    http://localhost:3001" -ForegroundColor Blue
Write-Host "Service2:    http://localhost:3002" -ForegroundColor Blue
Write-Host ""
Write-Host "To view logs: Receive-Job -Name Service1 -Keep" -ForegroundColor Yellow
Write-Host "To stop:      Get-Job | Stop-Job; Get-Job | Remove-Job" -ForegroundColor Yellow
Write-Host ""

