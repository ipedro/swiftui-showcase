#!/bin/bash
set -e
echo "Fixing header dates..."
echo ""
fixed=0
skipped=0
for file in $(find Sources Tests -name "*.swift" -type f); do
    current=$(sed -n '3s/.*on \([0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]\)\..*/\1/p' "$file")
    orig=$(git log --follow --format=%aD --reverse "$file" 2>/dev/null | head -1)
    if [ -n "$orig" ]; then
        formatted=$(date -j -f "%a, %d %b %Y %T %z" "$orig" "+%m/%d/%y" 2>/dev/null)
        if [ -n "$formatted" ] && [ "$current" != "$formatted" ]; then
            sed -i '' "3s|on [0-9][0-9]/[0-9][0-9]/[0-9][0-9]\.|on $formatted.|" "$file"
            new=$(sed -n '3s/.*on \([0-9][0-9]\/[0-9][0-9]\/[0-9][0-9]\)\..*/\1/p' "$file")
            if [ "$new" = "$formatted" ]; then
                echo "  ✓ $(basename $file): $current → $formatted"
                ((fixed++))
            fi
        elif [ "$current" = "$formatted" ]; then
            ((skipped++))
        fi
    fi
done
echo ""
[ $fixed -gt 0 ] && echo "✅ Fixed $fixed file(s)"
[ $skipped -gt 0 ] && echo "⏭️  Skipped $skipped (already correct)"
