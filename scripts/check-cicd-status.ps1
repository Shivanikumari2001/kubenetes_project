# CI/CD Status Check Script for PowerShell
# This script helps verify if your CI/CD pipeline is configured correctly

Write-Host "🔍 Checking CI/CD Pipeline Status..." -ForegroundColor Cyan
Write-Host ""

# Check if we're in a git repository
if (-not (Test-Path .git)) {
    Write-Host "❌ Not a git repository. Please run this from your project root." -ForegroundColor Red
    exit 1
}

# Check Git remotes
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "1️⃣  Git Repository Status" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

$remotes = git remote -v
if ($remotes) {
    Write-Host "✓ Git remotes configured:" -ForegroundColor Green
    $remotes | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    
    # Check if GitLab remote exists
    $hasGitLab = $remotes -match "gitlab"
    if ($hasGitLab) {
        Write-Host "✓ GitLab remote found" -ForegroundColor Green
    } else {
        Write-Host "⚠ No GitLab remote found. Add one with:" -ForegroundColor Yellow
        Write-Host "  git remote add origin https://gitlab.com/your-username/your-repo.git" -ForegroundColor Gray
    }
} else {
    Write-Host "❌ No git remotes configured" -ForegroundColor Red
    Write-Host "  Add a remote with: git remote add origin [url]" -ForegroundColor Gray
}

Write-Host ""

# Check for CI/CD files
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "2️⃣  CI/CD Configuration Files" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

$services = @("api-gateway", "service1", "service2")
$allFound = $true

foreach ($service in $services) {
    $ciFile = "$service\.gitlab-ci.yml"
    if (Test-Path $ciFile) {
        Write-Host "✓ $service/.gitlab-ci.yml exists" -ForegroundColor Green
        
        # Check image name in CI file
        $content = Get-Content $ciFile -Raw
        if ($content -match "IMAGE_NAME:\s*(.+)") {
            $imageName = $matches[1].Trim()
            Write-Host "  Image name: $imageName" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ $service/.gitlab-ci.yml NOT FOUND" -ForegroundColor Red
        $allFound = $false
    }
}

Write-Host ""

# Check git status
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "3️⃣  Git Status" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

$status = git status --short
if ($status) {
    Write-Host "⚠ You have uncommitted changes:" -ForegroundColor Yellow
    $status | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    Write-Host ""
    Write-Host "  Commit and push to trigger CI/CD:" -ForegroundColor Cyan
    Write-Host "    git add ." -ForegroundColor Gray
    Write-Host "    git commit -m 'test: trigger CI/CD'" -ForegroundColor Gray
    Write-Host "    git push origin main" -ForegroundColor Gray
} else {
    Write-Host "✓ Working directory is clean" -ForegroundColor Green
    
    # Check if there are unpushed commits
    $unpushed = git log origin/main..HEAD --oneline 2>$null
    if ($unpushed) {
        Write-Host "⚠ You have unpushed commits:" -ForegroundColor Yellow
        $unpushed | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        Write-Host ""
        Write-Host "  Push to trigger CI/CD:" -ForegroundColor Cyan
        Write-Host "    git push origin main" -ForegroundColor Gray
    } else {
        Write-Host "✓ All commits are pushed" -ForegroundColor Green
    }
}

Write-Host ""

# Check Docker images locally
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "4️⃣  Local Docker Images" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

$dockerImages = docker images --format "{{.Repository}}:{{.Tag}}" 2>$null
if ($dockerImages) {
    $expectedImages = @("wrakash/sky-gateway", "wrakash/sky-service1", "wrakash/sky-service2")
    foreach ($expected in $expectedImages) {
        $found = $dockerImages -match $expected
        if ($found) {
            Write-Host "✓ Found: $expected" -ForegroundColor Green
        } else {
            Write-Host "⚠ Not found locally: $expected" -ForegroundColor Yellow
            Write-Host "  (This is OK if images are only on Docker Hub)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "⚠ No Docker images found locally" -ForegroundColor Yellow
    Write-Host "  (This is OK if you're using Docker Hub images)" -ForegroundColor Gray
}

Write-Host ""

# Summary and next steps
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host "📋 Summary & Next Steps" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

Write-Host "To verify CI/CD is working:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Check GitLab CI/CD Variables:" -ForegroundColor White
Write-Host "   - Go to GitLab → Settings → CI/CD → Variables" -ForegroundColor Gray
Write-Host "   - Ensure DOCKER_HUB_USER and DOCKER_HUB_TOKEN are set" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Push code to trigger pipeline:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor Gray
Write-Host "   git commit -m 'test: trigger CI/CD'" -ForegroundColor Gray
Write-Host "   git push origin main" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Check pipeline status:" -ForegroundColor White
Write-Host "   - Go to GitLab → CI/CD → Pipelines" -ForegroundColor Gray
Write-Host "   - Watch the pipeline run (test → build → deploy)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Verify Docker images:" -ForegroundColor White
Write-Host "   - Go to https://hub.docker.com/u/wrakash" -ForegroundColor Gray
Write-Host "   - Check if new images were pushed" -ForegroundColor Gray
Write-Host ""
Write-Host "For detailed guide, see: HOW-TO-VERIFY-CICD.md" -ForegroundColor Cyan
Write-Host ""

