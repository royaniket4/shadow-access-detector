#!/bin/bash

echo "🔧 Shadow Access Detector Auto-Fix Script"

# Step 1: Ask for sudo if not root
if [ "$EUID" -ne 0 ]; then
  echo "🔐 Sudo required to fix permissions and move files"
  sudo bash "$0" "$@"
  exit $?
fi

# Step 2: Detect project root
ROOT_DIR=$(pwd)
echo "📁 Project root: $ROOT_DIR"

# Step 3: Detect scanner.py
if [ -f "$ROOT_DIR/backend/utils/scanner.py" ]; then
  echo "✅ scanner.py found at backend/utils/"
  SCANNER_PATH="$ROOT_DIR/backend/utils/scanner.py"
elif [ -f "$ROOT_DIR/utils/scanner.py" ]; then
  echo "✅ scanner.py already at utils/"
  SCANNER_PATH="$ROOT_DIR/utils/scanner.py"
else
  echo "❌ scanner.py not found. Creating dummy..."
  mkdir -p "$ROOT_DIR/utils"
  SCANNER_PATH="$ROOT_DIR/utils/scanner.py"
  cat <<EOF > "$SCANNER_PATH"
#!/usr/bin/env python3
import json
print(json.dumps([
  {"user": "aniket", "last_login": "Never", "risk": "High"},
  {"user": "ghost", "last_login": "Oct 10 2025", "risk": "Medium"},
  {"user": "admin", "last_login": "Oct 9 2025", "risk": "Low"}
]))
EOF
fi

# Step 4: Move scanner.py to utils/
if [[ "$SCANNER_PATH" != "$ROOT_DIR/utils/scanner.py" ]]; then
  echo "📦 Moving scanner.py to utils/"
  mkdir -p "$ROOT_DIR/utils"
  mv "$SCANNER_PATH" "$ROOT_DIR/utils/scanner.py"
fi

# Step 5: Patch app.js
APP_JS="$ROOT_DIR/backend/app.js"
if grep -q "backend/utils/scanner.py" "$APP_JS"; then
  echo "🛠️ Patching app.js to use __dirname/utils/scanner.py"
  sed -i 's|python3 backend/utils/scanner.py|python3 ${__dirname}/../utils/scanner.py|' "$APP_JS"
elif grep -q "utils/scanner.py" "$APP_JS"; then
  echo "✅ app.js already uses correct scanner path"
else
  echo "⚠️ Could not find scanner path in app.js — please check manually"
fi

# Step 6: Make scanner executable
chmod +x "$ROOT_DIR/utils/scanner.py"
echo "🔐 scanner.py made executable"

# Step 7: Final message
echo "🎉 Auto-fix complete!"
echo "➡️ Now run:"
echo "   cd backend && npm start"
echo "➡️ Then test:"
echo "   curl http://localhost:5000/api/scan"
