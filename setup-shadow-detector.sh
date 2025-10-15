#!/bin/bash

echo "🔧 Fixing Shadow Access Detector setup..."

# Step 1: Ensure scanner.py exists
SCANNER_PATH="backend/utils/scanner.py"
if [ ! -f "$SCANNER_PATH" ]; then
  echo "❌ scanner.py not found at $SCANNER_PATH"
  echo "📁 Creating dummy scanner.py for testing..."
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
  echo "✅ scanner.py found at $SCANNER_PATH"
fi

# Step 2: Make scanner executable
chmod +x $SCANNER_PATH
echo "🔐 scanner.py made executable."

# Step 3: Patch app.js to use absolute path
APP_PATH="backend/app.js"
if grep -q "python3 backend/utils/scanner.py" "$APP_PATH"; then
  echo "🛠️ Patching app.js to use __dirname..."
  sed -i 's|python3 backend/utils/scanner.py|python3 ${__dirname}/utils/scanner.py|' "$APP_PATH"
else
  echo "✅ app.js already uses correct path."
fi

# Step 4: Test scanner manually
echo "🧪 Testing scanner.py manually..."
echo "-----------------------------------"
python3 $SCANNER_PATH
echo "-----------------------------------"

# Step 5: Final message
echo "🎉 Setup complete. Now run:"
echo "   cd backend && npm start"
echo "Then test:"
echo "   curl http://localhost:5000/api/scan"
