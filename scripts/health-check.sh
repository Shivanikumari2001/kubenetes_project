#!/bin/bash

# Complete Health Check Script
# Checks all services, CI/CD status, and Kubernetes resources

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo "🏥 Complete Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

ERRORS=0
WARNINGS=0
SUCCESS=0

# Function to print section
print_section() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${CYAN}$1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Function to check command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check local services
print_section "1️⃣  Local Services Health Check"

check_service() {
    local name=$1
    local port=$2
    local url="http://localhost:${port}/health"
    
    if command_exists curl; then
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} $name is running on port $port"
            SUCCESS=$((SUCCESS + 1))
            return 0
        else
            echo -e "${RED}✗${NC} $name is NOT responding on port $port"
            ERRORS=$((ERRORS + 1))
            return 1
        fi
    else
        echo -e "${YELLOW}⚠${NC} curl not found, skipping HTTP health check"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

check_service "API Gateway" "3000"
check_service "Service1" "3001"
check_service "Service2" "3002"

# Check Docker containers
print_section "2️⃣  Docker Containers Status"

if command_exists docker; then
    if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "api-gateway|service1|service2" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Docker containers are running:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|api-gateway|service1|service2"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "${YELLOW}⚠${NC} No Docker containers found for microservices"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠${NC} Docker not installed, skipping container check"
    WARNINGS=$((WARNINGS + 1))
fi

# Check Kubernetes
print_section "3️⃣  Kubernetes Resources Status"

if command_exists kubectl; then
    if kubectl cluster-info &> /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Kubernetes cluster is accessible"
        SUCCESS=$((SUCCESS + 1))
        
        echo ""
        echo "Pods Status:"
        kubectl get pods 2>/dev/null | head -5 || echo "  No pods found"
        
        echo ""
        echo "Services Status:"
        kubectl get svc 2>/dev/null | grep -E "NAME|api-gateway|service1|service2" || echo "  No services found"
        
        echo ""
        echo "Deployments Status:"
        kubectl get deployments 2>/dev/null | grep -E "NAME|api-gateway|service1|service2" || echo "  No deployments found"
        
    else
        echo -e "${YELLOW}⚠${NC} Cannot connect to Kubernetes cluster"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠${NC} kubectl not installed, skipping Kubernetes check"
    WARNINGS=$((WARNINGS + 1))
fi

# Check ArgoCD
print_section "4️⃣  ArgoCD Status"

if command_exists kubectl && kubectl cluster-info &> /dev/null 2>&1; then
    if kubectl get namespace argocd &> /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} ArgoCD namespace exists"
        SUCCESS=$((SUCCESS + 1))
        
        ARGOCD_PODS=$(kubectl get pods -n argocd 2>/dev/null | grep -c Running || echo "0")
        if [ "$ARGOCD_PODS" -gt 0 ]; then
            echo -e "${GREEN}✓${NC} ArgoCD pods running: $ARGOCD_PODS"
            SUCCESS=$((SUCCESS + 1))
        else
            echo -e "${YELLOW}⚠${NC} No ArgoCD pods running"
            WARNINGS=$((WARNINGS + 1))
        fi
        
        echo ""
        echo "ArgoCD Applications:"
        kubectl get applications -n argocd 2>/dev/null || echo "  No applications found"
        
    else
        echo -e "${YELLOW}⚠${NC} ArgoCD namespace not found (ArgoCD may not be installed)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠${NC} Cannot check ArgoCD (kubectl or cluster not available)"
    WARNINGS=$((WARNINGS + 1))
fi

# Check CI/CD files
print_section "5️⃣  CI/CD Configuration Files"

SERVICES=("service1" "service2" "api-gateway")
for SERVICE in "${SERVICES[@]}"; do
    if [ -f "$SERVICE/.gitlab-ci.yml" ]; then
        echo -e "${GREEN}✓${NC} $SERVICE/.gitlab-ci.yml exists"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "${RED}✗${NC} $SERVICE/.gitlab-ci.yml missing"
        ERRORS=$((ERRORS + 1))
    fi
    
    if [ -f "$SERVICE/Dockerfile" ]; then
        echo -e "${GREEN}✓${NC} $SERVICE/Dockerfile exists"
    else
        echo -e "${YELLOW}⚠${NC} $SERVICE/Dockerfile missing"
        WARNINGS=$((WARNINGS + 1))
    fi
done

# Summary
print_section "📊 Health Check Summary"

echo "Total Checks: $((SUCCESS + WARNINGS + ERRORS))"
echo -e "${GREEN}✓ Passed: $SUCCESS${NC}"
echo -e "${YELLOW}⚠ Warnings: $WARNINGS${NC}"
echo -e "${RED}✗ Failed: $ERRORS${NC}"
echo ""

# Recommendations
if [ $ERRORS -gt 0 ] || [ $WARNINGS -gt 0 ]; then
    print_section "🛠️  Recommendations"
    
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}Issues Found:${NC}"
        echo "1. Fix any failed checks above"
        echo "2. Ensure services are running"
        echo "3. Check configuration files"
    fi
    
    if [ $WARNINGS -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}Warnings:${NC}"
        echo "1. Some checks were skipped (missing tools or services)"
        echo "2. This is normal if you're not using all features"
    fi
fi

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 Everything looks good!${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "For detailed CI/CD verification, run:"
echo -e "  ${BLUE}./scripts/verify-cicd-pipeline.sh${NC}"
echo ""
echo "For detailed guide, see:"
echo -e "  ${BLUE}VERIFICATION-GUIDE.md${NC}"
echo ""

# Exit with appropriate code
if [ $ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi

