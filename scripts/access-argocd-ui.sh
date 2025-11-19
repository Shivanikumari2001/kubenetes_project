#!/bin/bash

# Script to access ArgoCD UI with credentials

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🌐 Setting up ArgoCD UI Access..."
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗${NC} kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗${NC} Cannot connect to Kubernetes cluster"
    exit 1
fi

# Check if ArgoCD is installed
if ! kubectl get namespace argocd &> /dev/null; then
    echo -e "${RED}✗${NC} ArgoCD namespace not found"
    echo "Please install ArgoCD first: ./install-argocd.sh"
    exit 1
fi

# Get ArgoCD admin password
echo -e "${BLUE}Retrieving ArgoCD credentials...${NC}"
PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "")

if [ -z "$PASSWORD" ]; then
    echo -e "${RED}✗${NC} Could not retrieve ArgoCD password"
    echo "ArgoCD may still be initializing. Please wait a few minutes and try again."
    exit 1
fi

echo -e "${GREEN}✓${NC} Retrieved ArgoCD credentials"
echo ""

# Display credentials
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 ArgoCD Login Credentials"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "URL:      ${BLUE}https://localhost:8080${NC}"
echo -e "Username: ${GREEN}admin${NC}"
echo -e "Password: ${GREEN}$PASSWORD${NC}"
echo ""
echo -e "${YELLOW}⚠ Save these credentials securely!${NC}"
echo ""

# Check if port-forward is already running
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠${NC} Port 8080 is already in use"
    echo ""
    read -p "Do you want to kill the existing process and restart port-forward? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PID=$(lsof -Pi :8080 -sTCP:LISTEN -t)
        kill $PID 2>/dev/null || true
        sleep 2
    else
        echo "Keeping existing port-forward. Try accessing ArgoCD UI at https://localhost:8080"
        exit 0
    fi
fi

# Start port-forward
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Starting Port Forward"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}Port forwarding ArgoCD UI to localhost:8080...${NC}"
echo ""
echo "You can now access ArgoCD UI at: ${BLUE}https://localhost:8080${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} Accept the self-signed certificate warning in your browser"
echo ""
echo "Login with:"
echo "  Username: admin"
echo "  Password: $PASSWORD"
echo ""
echo -e "${RED}Press Ctrl+C to stop port forwarding${NC}"
echo ""

# Start port-forward (this will run in foreground)
kubectl port-forward svc/argocd-server -n argocd 8080:443

