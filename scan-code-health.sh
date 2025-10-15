#!/bin/bash

echo "🔍 Scanning project code health..."

ROOT_DIR="."
ERROR_LOG="code-scan-errors.log"
> "$ERROR_LOG"

# Step 1: Scan Python files
echo "🐍 Checking Python files..."
find "$ROOT_DIR" -path "*/node_modules/*" -prune -o -name "*.py" -print | while read -r file; do
  echo "🔧 python3 -m py_compile $file"
  python3 -m py_compile "$file" 2>>"$ERROR_LOG"
done

# Step 2: Scan JS/JSX/TS/TSX files with ESLint
echo "🟨 Checking JavaScript/React files with ESLint..."
if [ -f "frontend/package.json" ]; then
  cd frontend
  if npx eslint src --ext .js,.jsx,.ts,.tsx 2>>"../$ERROR_LOG"; then
    echo "✅ ESLint passed"
  else
    echo "❌ ESLint found issues"
  fi
  cd ..
else
  echo "⚠️ frontend/package.json not found — skipping ESLint"
fi

# Step 3: Show results
if [ -s "$ERROR_LOG" ]; then
  echo "❌ Issues found:"
  cat "$ERROR_LOG"
else
  echo "✅ No syntax or lint errors found in Python or JS/React files."
fi
