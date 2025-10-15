#!/bin/bash

echo "🔧 Fixing Shadow Access Detector setup..."

# 1. Ensure correct folder structure
if [ ! -f "utils/scanner.py" ]; then
  echo "📁 Moving scanner.py to correct location..."
  mkdir -p utils
  mv backend/utils/scanner.py utils/scanner.py 2>/dev/null
fi

# 2. Patch app.js to use absolute path
echo "🛠️ Patching app.js to use __dirname..."
sed -i 's|exec(\x27python3 backend/utils/scanner.py\x27|exec(`python3 \${__dirname}/utils/scanner.py`|' app.js

# 3. Make scanner executable
echo "🔐 Making scanner.py executable..."
chmod +x utils/scanner.py

# 4. Confirm structure
echo "📂 Verifying structure..."
if [ -f "utils/scanner.py" ]; then
  echo "✅ scanner.py found at utils/scanner.py"
else
  echo "❌ scanner.py not found — please check manually"
fi

# 5. Final message
echo "🎉 Setup fixed! Now run:"
echo "   cd backend && npm start"
