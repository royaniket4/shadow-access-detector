#!/bin/bash

echo "🚀 Starting backend with live debug..."

BACKEND_DIR="backend"
LOG_FILE="backend.log"

# Step 1: Check backend folder
if [ ! -d "$BACKEND_DIR" ]; then
  echo "❌ backend folder not found at $BACKEND_DIR"
  exit 1
fi

# Step 2: Go to backend
cd "$BACKEND_DIR"

# Step 3: Run npm start and capture logs
echo "📦 Running: npm start"
echo "----------------------------------------"
npm start > "../$LOG_FILE" 2>&1 &
PID=$!

# Step 4: Wait briefly and check if process is alive
sleep 3
if ps -p $PID > /dev/null; then
  echo "✅ Backend is running (PID: $PID)"
  echo "📄 Live logs (press Ctrl+C to stop):"
  echo "----------------------------------------"
  tail -f "../$LOG_FILE"
else
  echo "❌ Backend exited unexpectedly"
  echo "📄 Crash log:"
  echo "----------------------------------------"
  cat "../$LOG_FILE"
fi
