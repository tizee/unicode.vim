#!/bin/bash

# Test script to verify documentation works in Vim
# This script tests that the help system can find our documentation

echo "Testing Unicode plugin documentation..."

# Test that help tags were generated correctly
if [[ -f "doc/tags" ]]; then
    echo "✅ Help tags file exists"
    TAG_COUNT=$(wc -l < doc/tags)
    echo "   Found $TAG_COUNT help tags"
else
    echo "❌ Help tags file missing"
    exit 1
fi

# Test that documentation file exists
if [[ -f "doc/unicode.txt" ]]; then
    echo "✅ Documentation file exists"
    LINE_COUNT=$(wc -l < doc/unicode.txt)
    echo "   Documentation has $LINE_COUNT lines"
else
    echo "❌ Documentation file missing"
    exit 1
fi

# Test key sections exist in documentation
echo "Checking documentation sections..."

REQUIRED_SECTIONS=(
    "CONTENTS"
    "INTRODUCTION" 
    "INSTALLATION"
    "COMMANDS"
    "FUNCTIONS"
    "CONFIGURATION"
    "EXAMPLES"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$section" doc/unicode.txt; then
        echo "   ✅ $section section found"
    else
        echo "   ❌ $section section missing"
        exit 1
    fi
done

# Test key help tags exist
echo "Checking key help tags..."

KEY_TAGS=(
    "unicode"
    ":Unicode"
    ":GetUnicode" 
    "unicode#parse_formats()"
    "unicode#hex_to_char()"
    "g:debug_unicode_vim"
)

for tag in "${KEY_TAGS[@]}"; do
    if grep -q "$tag" doc/tags; then
        echo "   ✅ Tag '$tag' found"
    else
        echo "   ❌ Tag '$tag' missing"
        exit 1
    fi
done

echo ""
echo "🎉 Documentation test passed!"
echo ""
echo "To view the documentation in Vim, use:"
echo "   :help unicode"
echo "   :help :Unicode"
echo "   :help unicode#parse_formats()"
echo ""
echo "To test in a clean Vim environment:"
echo "   vim -u NONE -c 'helptags doc/' -c 'help unicode'"