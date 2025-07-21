#!/bin/bash

# Unicode Plugin Command Line Test Runner
# This script runs the Unicode plugin tests in a clean Vim environment

set -euo pipefail

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$SCRIPT_DIR"
TEST_DIR="$SCRIPT_DIR/test"
TEST_FILE="$TEST_DIR/test_unicode.vim"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if vim is available
if ! command -v vim >/dev/null 2>&1; then
    echo_error "vim is not installed or not in PATH"
    exit 1
fi

echo_info "Starting Unicode Plugin Tests in Clean Environment"
echo_info "Plugin directory: $PLUGIN_DIR"
echo_info "Test directory: $TEST_DIR"

# Create test directory if it doesn't exist
mkdir -p "$TEST_DIR"

# Clean up any old test output files
rm -f "$TEST_DIR"/test_*.log

# Check if plugin file exists
if [[ ! -f "$PLUGIN_DIR/plugin/unicode.vim" ]]; then
    echo_error "Plugin file not found: $PLUGIN_DIR/plugin/unicode.vim"
    exit 1
fi

# Check if test file exists
if [[ ! -f "$TEST_FILE" ]]; then
    echo_error "Test file not found: $TEST_FILE"
    exit 1
fi

echo_info "Running tests with clean Vim configuration..."

# Run the tests in vim with clean environment
# -u NONE: use no vimrc
# --noplugin: don't load standard plugins
# -n: no swap file
# -i NONE: no viminfo file
# -c: execute command after loading files
vim \
    -u NONE \
    --noplugin \
    -n \
    -i NONE \
    -c "set nomore" \
    -c "set runtimepath+=$PLUGIN_DIR" \
    -c "source $TEST_FILE" \
    -c "call RunTestsAndExit()"

# Check the exit code from Vim
EXIT_CODE=$?

echo_info "Test execution completed with exit code: $EXIT_CODE"

# Vim exit codes:
# 0 = success (all tests passed)  
# 1 = failure (some tests failed or error occurred)
if [[ $EXIT_CODE -eq 0 ]]; then
    echo_info "🎉 All tests passed!"
    exit 0
else
    echo_error "❌ Tests failed or error occurred (see details above)"
    exit 1
fi