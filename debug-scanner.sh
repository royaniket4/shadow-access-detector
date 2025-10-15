#!/bin/bash

echo "🔍 Shadow Access Detector: Scanner Debugger"

SCANNER_PATH="utils/scanner.py"

# Step 1: Check if scanner.py exists
if [ ! -f "$SCANNER_PATH" ]; then
  echo "❌ scanner.py not found at $SCANNER_PATH"
  exit 1
fi

echo "✅ scanner.py found at $SCANNER_PATH"
echo "🔐 Making sure it's executable..."
chmod +x "$SCANNER_PATH"

# Step 2: Run scanner.py and capture output
echo "🚀 Running: python3 $SCANNER_PATH"
echo "----------------------------------------"

STDOUT=$(python3 "$SCANNER_PATH")
EXIT_CODE=$?
echo "📤 stdout:"
echo "$STDOUT"
echo "⚠️ exit code: $EXIT_CODE"

# Step 3: Validate JSON
echo "$STDOUT" | python3 -c "import sys, json; json.load(sys.stdin)" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "✅ JSON output is valid"
else
  echo "❌ JSON output is invalid"
fi

# Step 4: Backend path check
echo "🔍 Checking backend app.js for correct scanner path..."
grep "utils/scanner.py" backend/app.js && echo "✅ Path looks correct" || echo "❌ Path not found — check app.js"
