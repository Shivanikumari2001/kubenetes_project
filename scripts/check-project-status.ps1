# Quick Project Status Check Script
# Checks if all services are running and responding

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🔍 Checking Project Status" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$allRunning = $true

# Function to test endpoint
function Test-Service {
    param($Url, $Name, $Port)
    
    $portText = "Port $Port"
    Write-Host "Checking $Name ($portText)..." -ForegroundColor Yellow -NoNewline
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host " ✅ RUNNING" -ForegroundColor Green
        if ($response.Content) {
            $contentPreview = $response.Content.Substring(0, [Math]::Min(50, $response.Content.Length))
            Write-Host "   Status $($response.StatusCode)" -ForegroundColor Gray
            Write-Host "   Preview $contentPreview..." -ForegroundColor Gray
        } else {
            Write-Host "   Status $($response.StatusCode)" -ForegroundColor Gray
        }
        return $true
    }
    catch {
        Write-Host " ❌ NOT RUNNING" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
        return $false
    }
}

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "1️⃣  Checking Ports" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Check ports
$port3000 = (Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue) -ne $null
$port3001 = (Get-NetTCPConnection -LocalPort 3001 -State Listen -ErrorAction SilentlyContinue) -ne $null
$port3002 = (Get-NetTCPConnection -LocalPort 3002 -State Listen -ErrorAction SilentlyContinue) -ne $null

Write-Host 'Port 3000 (API Gateway): ' -NoNewline
if ($port3000) { Write-Host "LISTENING ✅" -ForegroundColor Green } else { Write-Host "NOT IN USE ❌" -ForegroundColor Red; $allRunning = $false }

Write-Host 'Port 3001 (Service1):    ' -NoNewline
if ($port3001) { Write-Host "LISTENING ✅" -ForegroundColor Green } else { Write-Host "NOT IN USE ❌" -ForegroundColor Red; $allRunning = $false }

Write-Host 'Port 3002 (Service2):    ' -NoNewline
if ($port3002) { Write-Host "LISTENING ✅" -ForegroundColor Green } else { Write-Host "NOT IN USE ❌" -ForegroundColor Red; $allRunning = $false }

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "2️⃣  Testing Health Endpoints" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Test endpoints
$apiGateway = Test-Service "http://localhost:3000/health" "API Gateway" "3000"
$service1 = Test-Service "http://localhost:3001/health" "Service1" "3001"
$service2 = Test-Service "http://localhost:3002/health" "Service2" "3002"

if (-not $apiGateway) { $allRunning = $false }
if (-not $service1) { $allRunning = $false }
if (-not $service2) { $allRunning = $false }

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "3️⃣  Testing API Gateway Routing" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

if ($apiGateway -and $service1) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/users" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host "✅ Gateway → Service1 routing: WORKING" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Gateway → Service1 routing: FAILED" -ForegroundColor Red
        $allRunning = $false
    }
} else {
    Write-Host "⚠ Gateway → Service1 routing: SKIPPED (services not ready)" -ForegroundColor Yellow
}

if ($apiGateway -and $service2) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/api/payments" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
        Write-Host "✅ Gateway → Service2 routing: WORKING" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Gateway → Service2 routing: FAILED" -ForegroundColor Red
        $allRunning = $false
    }
} else {
    Write-Host "⚠ Gateway → Service2 routing: SKIPPED (services not ready)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "4️⃣  Checking Background Jobs" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

$jobs = Get-Job -ErrorAction SilentlyContinue | Where-Object { $_.Name -in @("Service1", "Service2", "APIGateway") }
if ($jobs) {
    $jobs | Format-Table Id, Name, State, HasMoreData
} else {
    Write-Host "⚠ No background jobs found (services may be running in separate terminals)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

if ($allRunning) {
    Write-Host "🎉 All services are RUNNING successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Access URLs:" -ForegroundColor Cyan
    Write-Host "  API Gateway: http://localhost:3000" -ForegroundColor Blue
    Write-Host "  Service1:    http://localhost:3001" -ForegroundColor Blue
    Write-Host "  Service2:    http://localhost:3002" -ForegroundColor Blue
    exit 0
} else {
    Write-Host "⚠ Some services are NOT running!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To start services, run:" -ForegroundColor Cyan
    Write-Host "  .\scripts\start-services.ps1" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Or manually:" -ForegroundColor Cyan
    Write-Host "  cd service1 && npm run start:dev" -ForegroundColor Blue
    Write-Host "  cd service2 && npm run start:dev" -ForegroundColor Blue
    Write-Host "  cd api-gateway && npm run start:dev" -ForegroundColor Blue
    exit 1
}

