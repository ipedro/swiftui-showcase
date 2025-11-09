#!/usr/bin/env python3
"""
Convert xccov JSON output to lcov format for Codecov upload.
Usage: python xccov_to_lcov.py coverage.json coverage.lcov
"""

import json
import sys
from pathlib import Path


def convert_xccov_to_lcov(json_path: str, lcov_path: str) -> None:
    """Convert xccov JSON coverage to lcov format."""
    with open(json_path) as f:
        data = json.load(f)
    
    with open(lcov_path, 'w') as out:
        for target in data.get('targets', []):
            for file_data in target.get('files', []):
                path = file_data['path']
                out.write(f"TN:\n")
                out.write(f"SF:{path}\n")
                
                # Process functions
                for func in file_data.get('functions', []):
                    name = func['name']
                    line = func['lineNumber']
                    count = func['executionCount']
                    out.write(f"FN:{line},{name}\n")
                    out.write(f"FNDA:{count},{name}\n")
                
                # Function summary
                total_functions = len(file_data.get('functions', []))
                covered_functions = sum(1 for f in file_data.get('functions', []) if f['executionCount'] > 0)
                out.write(f"FNF:{total_functions}\n")
                out.write(f"FNH:{covered_functions}\n")
                
                # Process lines
                for func in file_data.get('functions', []):
                    line = func['lineNumber']
                    count = func['executionCount']
                    out.write(f"DA:{line},{count}\n")
                
                # Line summary
                out.write(f"LF:{file_data['executableLines']}\n")
                out.write(f"LH:{file_data['coveredLines']}\n")
                
                out.write("end_of_record\n")


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python xccov_to_lcov.py <input.json> <output.lcov>")
        sys.exit(1)
    
    convert_xccov_to_lcov(sys.argv[1], sys.argv[2])
    print(f"Converted {sys.argv[1]} to {sys.argv[2]}")
