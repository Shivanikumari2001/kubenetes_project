#!/bin/bash

# Script to apply ArgoCD applications for all microservices

set -e

echo "🚀 Applying ArgoCD Applications..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗${NC} kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗${NC} Cannot connect to Kubernetes cluster"
    echo "Please ensure kubectl is configured correctly"
    exit 1
fi

# Check if ArgoCD CRDs are installed
if ! kubectl get crd applications.argoproj.io &> /dev/null; then
    echo -e "${RED}✗${NC} ArgoCD is not installed in the cluster"
    echo ""
    echo -e "${YELLOW}ArgoCD CRDs are missing. Please install ArgoCD first.${NC}"
    echo ""
    echo "To install ArgoCD, run:"
    echo -e "${BLUE}  ./install-argocd.sh${NC}"
    echo ""
    echo "Or manually install ArgoCD:"
    echo -e "${BLUE}  kubectl create namespace argocd${NC}"
    echo -e "${BLUE}  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml${NC}"
    echo ""
    exit 1
fi

# Check if ArgoCD namespace exists
if ! kubectl get namespace argocd &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} ArgoCD namespace not found. Creating it..."
    kubectl create namespace argocd
fi

# Apply ArgoCD applications
SERVICES=("api-gateway" "service1" "service2")

for SERVICE in "${SERVICES[@]}"; do
    APP_FILE="$SERVICE/argocd/application.yaml"
    
    if [ -f "$APP_FILE" ]; then
        echo -e "${GREEN}Applying${NC} ArgoCD application for $SERVICE..."
        kubectl apply -f "$APP_FILE"
        
        # Wait a moment and check status
        sleep 2
        if kubectl get application "$SERVICE" -n argocd &> /dev/null; then
            echo -e "${GREEN}✓${NC} Application '$SERVICE' applied successfully"
        else
            echo -e "${YELLOW}⚠${NC} Application '$SERVICE' may not be ready yet"
        fi
    else
        echo -e "${YELLOW}⚠${NC} ArgoCD application file not found: $APP_FILE"
    fi
    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 ArgoCD Applications Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show all applications
kubectl get applications -n argocd 2>/dev/null || echo "No applications found or ArgoCD not installed"

echo ""
echo "To view detailed status, run:"
echo "  kubectl get applications -n argocd"
echo "  kubectl describe application <app-name> -n argocd"
echo ""
echo "To access ArgoCD UI, run:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Then visit: https://localhost:8080"
echo "  Default username: admin"
echo "  Get password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"

