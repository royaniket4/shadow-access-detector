#!/bin/bash

echo "🧹 Starting cleanup for Shadow Access Detector..."

# Navigate to project root
cd "$(dirname "$0")"

# Confirm we're inside shadow-access-detector
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
  echo "❌ Error: backend or frontend folder missing. Are you in the right directory?"
  exit 1
fi

# Remove nested shadow-access-detector folders if any
find . -type d -name "shadow-access-detector" -not -path "./shadow-access-detector" -exec rm -rf {} +

# Remove node_modules and lock files
echo "🧨 Removing node_modules and lock files..."
rm -rf backend/node_modules backend/package-lock.json
rm -rf frontend/node_modules frontend/package-lock.json

# Remove .git folders
echo "🧨 Removing .git folders..."
find . -type d -name ".git" -exec rm -rf {} +

# Remove system junk
echo "🧨 Removing system junk files..."
find . -name ".DS_Store" -type f -delete

# Remove README.md if empty or default
if grep -q "This project was bootstrapped with Create React App" frontend/README.md 2>/dev/null; then
  echo "🧨 Removing default README.md..."
  rm -f frontend/README.md
fi

# Remove test files
echo "🧨 Removing test files..."
find frontend/src -name "*.test.js" -type f -delete

# Final structure check
echo "✅ Cleanup complete. Final structure:"
tree -L 2

echo "👉 You can now run './setup.sh' again for a fresh build."
