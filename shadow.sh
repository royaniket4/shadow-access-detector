#!/bin/bash

echo "🚀 Shadow Access Detector Launcher"

# Check backend
if [ -d "backend" ]; then
  echo "🖥️ Starting backend..."
  (cd backend && npm start) &
else
  echo "❌ Backend folder not found."
fi

# Check frontend
if [ -d "frontend" ]; then
  echo "🌐 Starting frontend..."
  (cd frontend && npm start) &
else
  echo "❌ Frontend folder not found."
fi

# Wait for both to launch
sleep 2
echo "✅ Both services launched. Open http://localhost:3000 in browser."
