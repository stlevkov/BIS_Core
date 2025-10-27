#!/bin/bash
# BIS_Core Addon Validation Script
# Run this script to validate the addon before committing changes

set -e

echo "=== BIS_Core Addon Validation ==="
echo "Repository: $(pwd)"
echo ""

# Check if we're in the right directory
if [ ! -f "BIS_Core.toc" ]; then
    echo "❌ Error: BIS_Core.toc not found. Run this script from the addon root directory."
    exit 1
fi

echo "✅ Found BIS_Core.toc"

# Check if lua5.3 is available
if ! command -v luac5.3 &> /dev/null; then
    echo "❌ Error: luac5.3 not found. Install with: sudo apt-get install -y lua5.3"
    exit 1
fi

echo "✅ Found luac5.3"

# Verify all .toc files exist
echo ""
echo "🔍 Checking file structure..."
missing_files=0
while read -r file; do
    if [[ "$file" == *.lua ]]; then
        if [ -f "$file" ]; then
            echo "  ✅ $file"
        else
            echo "  ❌ Missing: $file"
            missing_files=$((missing_files + 1))
        fi
    fi
done < BIS_Core.toc

if [ $missing_files -gt 0 ]; then
    echo "❌ Error: $missing_files file(s) missing from addon structure"
    exit 1
fi

# Syntax validation
echo ""
echo "🔍 Validating Lua syntax..."
syntax_errors=0
for file in *.lua; do
    if luac5.3 -p "$file" 2>/dev/null; then
        echo "  ✅ $file"
    else
        echo "  ❌ Syntax error in $file"
        luac5.3 -p "$file"
        syntax_errors=$((syntax_errors + 1))
    fi
done

if [ $syntax_errors -gt 0 ]; then
    echo "❌ Error: $syntax_errors file(s) have syntax errors"
    exit 1
fi

# Summary
echo ""
echo "🎉 All validations passed!"
echo "📊 Files validated: $(ls *.lua | wc -l)"
echo "📊 Total lines: $(cat *.lua | wc -l)"
echo "📊 Repository size: $(du -sh . | cut -f1)"
echo ""
echo "✅ Addon is ready for testing in World of Warcraft"