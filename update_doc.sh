#!/bin/bash

# Script to regenerate help tags after documentation updates

echo "Regenerating Vim help tags..."

if [[ ! -d "doc" ]]; then
    echo "❌ Error: doc/ directory not found"
    echo "Run this script from the plugin root directory"
    exit 1
fi

if [[ ! -f "doc/unicode.txt" ]]; then
    echo "❌ Error: doc/unicode.txt not found"
    exit 1
fi

# Generate help tags
vim -u NONE -c "helptags doc/" -c "quit"

if [[ -f "doc/tags" ]]; then
    TAG_COUNT=$(wc -l < doc/tags)
    echo "✅ Help tags regenerated successfully"
    echo "   Generated $TAG_COUNT help tags"
    
    echo ""
    echo "Updated tags:"
    cat doc/tags | cut -f1 | sort
    
    echo ""
    echo "To test the documentation:"
    echo "   vim -c 'help unicode'"
else
    echo "❌ Error: Failed to generate help tags"
    exit 1
fi