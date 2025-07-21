#!/bin/bash

# Unicode.vim Version Information Script
# Displays current version and git information

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Get plugin version
PLUGIN_FILE="plugin/unicode.vim"
if [[ -f "$PLUGIN_FILE" ]]; then
    VERSION=$(grep "let g:unicode_vim_version = " "$PLUGIN_FILE" | sed -E "s/.*= '([^']+)'.*/\1/")
    echo_step "Unicode.vim Version Information"
    echo "=========================================="
    echo_info "Plugin version: v$VERSION"
else
    echo "❌ Plugin file not found: $PLUGIN_FILE"
    exit 1
fi

# Check if we're in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Get git information
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s")
    COMMIT_DATE=$(git log -1 --pretty=format:"%ai")
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    echo_info "Git branch: $BRANCH"
    echo_info "Latest commit: ${COMMIT_HASH:0:8}"
    echo_info "Commit message: \"$COMMIT_MESSAGE\""
    echo_info "Commit date: $COMMIT_DATE"
    
    # Check if tag exists for current version
    if git tag -l | grep -q "^v$VERSION$"; then
        echo_info "✅ Git tag v$VERSION exists"
    else
        echo -e "${YELLOW}[WARN]${NC} Git tag v$VERSION does not exist"
    fi
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo -e "${YELLOW}[WARN]${NC} You have uncommitted changes"
    else
        echo_info "✅ Working directory is clean"
    fi
else
    echo -e "${YELLOW}[WARN]${NC} Not in a git repository"
fi

echo ""