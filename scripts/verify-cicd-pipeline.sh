#!/bin/bash

# CI/CD Pipeline Verification Script
# This script verifies that the CI/CD pipeline is properly configured

set -e

echo "🔍 Verifying CI/CD Pipeline Configuration..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Track validation results
ERRORS=0
WARNINGS=0
SUCCESS=0

# Function to print section header
print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Check Kubernetes cluster
print_header "1️⃣  Kubernetes Cluster Status"
if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓${NC} Kubernetes cluster is accessible"
    SUCCESS=$((SUCCESS + 1))
else
    echo -e "${RED}✗${NC} Cannot connect to Kubernetes cluster"
    ERRORS=$((ERRORS + 1))
fi

# Check ArgoCD installation
print_header "2️⃣  ArgoCD Installation Status"
if kubectl get namespace argocd &> /dev/null; then
    echo -e "${GREEN}✓${NC} ArgoCD namespace exists"
    
    # Check ArgoCD pods
    READY_PODS=$(kubectl get pods -n argocd --field-selector=status.phase=Running 2>/dev/null | grep -c Running || echo 0)
    TOTAL_PODS=$(kubectl get pods -n argocd 2>/dev/null | grep -c argocd || echo 0)
    
    if [ $READY_PODS -eq $TOTAL_PODS ] && [ $READY_PODS -gt 0 ]; then
        echo -e "${GREEN}✓${NC} All ArgoCD pods are running ($READY_PODS/$TOTAL_PODS)"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "${YELLOW}⚠${NC} Some ArgoCD pods are not ready ($READY_PODS/$TOTAL_PODS)"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${RED}✗${NC} ArgoCD is not installed"
    ERRORS=$((ERRORS + 1))
fi

# Check GitHub credentials
print_header "3️⃣  GitHub Repository Access"
if kubectl get secret github-creds -n argocd &> /dev/null; then
    echo -e "${GREEN}✓${NC} GitHub credentials secret exists in ArgoCD"
    SUCCESS=$((SUCCESS + 1))
else
    echo -e "${RED}✗${NC} GitHub credentials not configured in ArgoCD"
    echo "   Run: ./configure-argocd-git.sh"
    ERRORS=$((ERRORS + 1))
fi

# Check ArgoCD applications
print_header "4️⃣  ArgoCD Applications Status"
SERVICES=("api-gateway" "service1" "service2")

for SERVICE in "${SERVICES[@]}"; do
    if kubectl get application $SERVICE -n argocd &> /dev/null; then
        SYNC_STATUS=$(kubectl get application $SERVICE -n argocd -o jsonpath='{.status.sync.status}' 2>/dev/null || echo "Unknown")
        HEALTH_STATUS=$(kubectl get application $SERVICE -n argocd -o jsonpath='{.status.health.status}' 2>/dev/null || echo "Unknown")
        
        echo -n "  $SERVICE: "
        
        if [ "$SYNC_STATUS" = "Synced" ]; then
            echo -n -e "${GREEN}Synced${NC}"
        elif [ "$SYNC_STATUS" = "Unknown" ]; then
            echo -n -e "${YELLOW}Unknown${NC}"
        else
            echo -n -e "${RED}$SYNC_STATUS${NC}"
        fi
        
        echo -n " | "
        
        if [ "$HEALTH_STATUS" = "Healthy" ]; then
            echo -e "${GREEN}Healthy${NC}"
            SUCCESS=$((SUCCESS + 1))
        elif [ "$HEALTH_STATUS" = "Progressing" ]; then
            echo -e "${YELLOW}Progressing${NC}"
            WARNINGS=$((WARNINGS + 1))
        else
            echo -e "${RED}$HEALTH_STATUS${NC}"
            ERRORS=$((ERRORS + 1))
        fi
        
        # Check for errors
        ERROR_MSG=$(kubectl get application $SERVICE -n argocd -o jsonpath='{.status.conditions[?(@.type=="ComparisonError")].message}' 2>/dev/null || echo "")
        if [ ! -z "$ERROR_MSG" ]; then
            echo -e "    ${RED}Error:${NC} $ERROR_MSG"
        fi
    else
        echo -e "${RED}✗${NC} Application '$SERVICE' not found"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check CI/CD files
print_header "5️⃣  GitLab CI/CD Configuration Files"
for SERVICE in "${SERVICES[@]}"; do
    if [ -f "$SERVICE/.gitlab-ci.yml" ]; then
        echo -e "${GREEN}✓${NC} $SERVICE/.gitlab-ci.yml exists"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "${RED}✗${NC} $SERVICE/.gitlab-ci.yml missing"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check Dockerfiles
print_header "6️⃣  Docker Configuration"
for SERVICE in "${SERVICES[@]}"; do
    if [ -f "$SERVICE/Dockerfile" ]; then
        echo -e "${GREEN}✓${NC} $SERVICE/Dockerfile exists"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "${RED}✗${NC} $SERVICE/Dockerfile missing"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check Helm charts
print_header "7️⃣  Helm Charts"
for SERVICE in "${SERVICES[@]}"; do
    if [ -f "$SERVICE/helm/Chart.yaml" ]; then
        echo -e "${GREEN}✓${NC} $SERVICE/helm/Chart.yaml exists"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "${RED}✗${NC} $SERVICE/helm/Chart.yaml missing"
        ERRORS=$((ERRORS + 1))
    fi
    
    if [ -f "$SERVICE/helm/values.yaml" ]; then
        echo -e "${GREEN}✓${NC} $SERVICE/helm/values.yaml exists"
    else
        echo -e "${RED}✗${NC} $SERVICE/helm/values.yaml missing"
        ERRORS=$((ERRORS + 1))
    fi
done

# Summary
print_header "📊 Verification Summary"
echo "Total Checks: $((SUCCESS + WARNINGS + ERRORS))"
echo -e "${GREEN}✓ Passed: $SUCCESS${NC}"
echo -e "${YELLOW}⚠ Warnings: $WARNINGS${NC}"
echo -e "${RED}✗ Failed: $ERRORS${NC}"
echo ""

# Recommendations
if [ $ERRORS -gt 0 ]; then
    print_header "🛠️  Recommended Actions"
    echo "1. Review the errors above and fix any missing configurations"
    echo "2. If ArgoCD applications show 'Unknown' status, this may be normal if:"
    echo "   - The Helm charts don't exist in the GitHub repositories yet"
    echo "   - The repositories are empty or don't have a 'helm' directory"
    echo "3. To push your local code to GitHub repositories:"
    echo "   - Make sure the repositories exist on GitHub"
    echo "   - Add the remote and push your code"
    echo "4. Check detailed troubleshooting: cat TROUBLESHOOTING-REPORT.md"
fi

print_header "🚀 Next Steps"
echo "1. Access ArgoCD UI:"
echo -e "   ${BLUE}./access-argocd-ui.sh${NC}"
echo ""
echo "2. Push code to GitHub to trigger CI/CD pipeline:"
echo -e "   ${BLUE}git add .${NC}"
echo -e "   ${BLUE}git commit -m 'test: trigger CI/CD'${NC}"
echo -e "   ${BLUE}git push origin main${NC}"
echo ""
echo "3. Monitor pipeline in GitLab:"
echo "   - Go to your GitLab project → CI/CD → Pipelines"
echo "   - Watch the test and build stages run automatically"
echo "   - After build succeeds, manually trigger 'update-helm-chart'"
echo ""
echo "4. Watch ArgoCD sync your application:"
echo "   - Open ArgoCD UI (step 1)"
echo "   - Watch the applications sync automatically"
echo ""

# Exit with appropriate code
if [ $ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi

