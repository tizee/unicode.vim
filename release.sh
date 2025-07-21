#!/bin/bash

# Unicode.vim Release Script
# Automatically creates git tags using current commit message and plugin version

set -euo pipefail

# Parse command line arguments
DRY_RUN=false
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|-d)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            HELP=true
            break
            ;;
    esac
done

if [[ "$HELP" == true ]]; then
    echo "Unicode.vim Release Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  --dry-run, -d    Show what would be done without making changes"
    echo "  --help, -h       Show this help message"
    echo ""
    echo "This script will:"
    echo "  1. Extract version from plugin/unicode.vim"
    echo "  2. Check for uncommitted changes"
    echo "  3. Create git tag using current commit message"
    echo "  4. Optionally push tag to remote"
    exit 0
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo_error "Not in a git repository"
    exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
    echo_step "Unicode.vim Release Script (DRY RUN MODE)"
else
    echo_step "Unicode.vim Release Script"
fi
echo "=========================================="

# Get current plugin version from plugin file
PLUGIN_FILE="plugin/unicode.vim"
if [[ ! -f "$PLUGIN_FILE" ]]; then
    echo_error "Plugin file not found: $PLUGIN_FILE"
    exit 1
fi

# Extract version from plugin file
VERSION=$(grep "let g:unicode_vim_version = " "$PLUGIN_FILE" | sed -E "s/.*= '([^']+)'.*/\1/")

if [[ -z "$VERSION" ]]; then
    echo_error "Could not extract version from $PLUGIN_FILE"
    exit 1
fi

echo_info "Current plugin version: $VERSION"

# Check if tag already exists
if git tag -l | grep -q "^v$VERSION$"; then
    echo_error "Tag v$VERSION already exists"
    echo_info "Existing tags:"
    git tag -l | grep "^v" | sort -V
    exit 1
fi

# Check if we have uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo_error "You have uncommitted changes. Please commit or stash them first."
    git status --short
    exit 1
fi

# Get current commit hash and message
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MESSAGE=$(git log -1 --pretty=format:"%s")
COMMIT_AUTHOR=$(git log -1 --pretty=format:"%an")
COMMIT_DATE=$(git log -1 --pretty=format:"%ai")

echo_info "Current commit: ${COMMIT_HASH:0:8}"
echo_info "Commit message: \"$COMMIT_MESSAGE\""
echo_info "Commit author: $COMMIT_AUTHOR"
echo_info "Commit date: $COMMIT_DATE"

# Create tag message
TAG_MESSAGE="Release v$VERSION

$COMMIT_MESSAGE

Author: $COMMIT_AUTHOR
Date: $COMMIT_DATE"

echo ""
echo_step "Creating git tag v$VERSION"
echo "Tag message:"
echo "----------------------------------------"
echo "$TAG_MESSAGE"
echo "----------------------------------------"

if [[ "$DRY_RUN" == true ]]; then
    echo ""
    echo_step "DRY RUN - Would execute the following commands:"
    echo "git tag -a \"v$VERSION\" -m \"$TAG_MESSAGE\""
    echo "git push origin \"v$VERSION\" (if confirmed)"
    echo ""
    echo_info "✅ Dry run completed - no changes made"
else
    # Ask for confirmation
    echo ""
    read -p "$(echo -e ${YELLOW}Create tag v$VERSION with this message? [y/N]: ${NC})" -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo_info "Release cancelled"
        exit 0
    fi

    # Create the annotated tag
    git tag -a "v$VERSION" -m "$TAG_MESSAGE"

    echo_info "✅ Tag v$VERSION created successfully"

    # Ask if user wants to push the tag
    echo ""
    read -p "$(echo -e ${YELLOW}Push tag to remote origin? [y/N]: ${NC})" -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo_step "Pushing tag to remote..."
        git push origin "v$VERSION"
        echo_info "✅ Tag v$VERSION pushed to remote"
    else
        echo_info "Tag created locally only. To push later, run:"
        echo "   git push origin v$VERSION"
    fi
fi

echo ""
echo_step "Release Summary"
echo "=========================================="
echo_info "Version: v$VERSION"
echo_info "Tag: v$VERSION"
echo_info "Commit: ${COMMIT_HASH:0:8}"
echo_info "Message: \"$COMMIT_MESSAGE\""

echo ""
echo_step "Next Steps"
echo "- Update CHANGELOG.md if needed"
echo "- Create GitHub release at: https://github.com/tizee/unicode.vim/releases/new?tag=v$VERSION"
echo "- Update plugin manager documentation if needed"

echo ""
echo_info "🎉 Release v$VERSION completed successfully!"