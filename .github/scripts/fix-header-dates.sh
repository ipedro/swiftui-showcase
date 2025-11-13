#!/bin/bash

# Fix file header dates based on git history
# This script restores the original creation dates in file headers after SwiftFormat runs

set -e

echo "Fixing header dates based on git history..."

fixed_count=0

for file in $(git diff --name-only --diff-filter=M | grep -E '\.(swift|h|m)$'); do
    if [ -f "$file" ]; then
        # Get the original creation date from git (first commit)
        original_date=$(git log --follow --format=%aD --reverse "$file" 2>/dev/null | head -1)
        
        if [ -n "$original_date" ]; then
            # Convert to MM/DD/YY format
            formatted_date=$(date -j -f "%a, %d %b %Y %T %z" "$original_date" "+%m/%d/%y" 2>/dev/null)
            
            if [ -n "$formatted_date" ]; then
                # Replace the date in the file (line 3: "Created by Pedro Almeida on XX/XX/XX.")
                if sed -i '' "3s|on [0-9][0-9]/[0-9][0-9]/[0-9][0-9]\.|on $formatted_date.|" "$file" 2>/dev/null; then
                    fixed_count=$((fixed_count + 1))
                fi
            fi
        fi
    fi
done

if [ $fixed_count -gt 0 ]; then
    echo "✅ Fixed dates in $fixed_count file(s)"
else
    echo "✅ No dates needed fixing"
fi
