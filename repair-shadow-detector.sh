#!/bin/bash

echo "🔧 Starting runtime repair for Shadow Access Detector..."

SCANNER_PATH="backend/utils/scanner.py"
APP_PATH="backend/app.js"

# Step 1: Ensure scanner.py exists
if [ ! -f "$SCANNER_PATH" ]; then
  echo "❌ scanner.py missing. Creating dummy scanner..."
  mkdir -p backend/utils
  cat <<EOF > $SCANNER_PATH
#!/usr/bin/env python3
import json
print(json.dumps([
  {"user": "aniket", "last_login": "Never", "risk": "High"},
  {"user": "ghost", "last_login": "Oct 10 2025", "risk": "Medium"},
  {"user": "admin", "last_login": "Oct 9 2025", "risk": "Low"}
]))
EOF
else
  echo "✅ scanner.py found."
fi

# Step 2: Make scanner executable
chmod +x "$SCANNER_PATH"
echo "🔐 scanner.py made executable."

# Step 3: Patch app.js if needed
if grep -q "python3 backend/utils/scanner.py" "$APP_PATH"; then
  echo "🛠️ Patching app.js to use __dirname..."
  sed -i 's|python3 backend/utils/scanner.py|python3 ${__dirname}/utils/scanner.py|' "$APP_PATH"
else
  echo "✅ app.js already uses correct path."
fi

# Step 4: Test scanner manually
echo "🧪 Testing scanner.py manually..."
SCAN_OUTPUT=$(python3 "$SCANNER_PATH")
echo "📤 Output:"
echo "$SCAN_OUTPUT"

# Step 5: Validate JSON
echo "$SCAN_OUTPUT" | python3 -c "import sys, json; json.load(sys.stdin)" 2>/dev/null
if [ $? -eq 0 ]; then
  echo "✅ JSON is valid."
else
  echo "❌ JSON parse failed — scanner output is broken."
fi

# Step 6: Final curl test
echo "🌐 Testing backend API..."
curl -s http://localhost:5000/api/scan || echo "❌ curl failed — backend may not be running"

echo "🎉 Runtime repair complete."
