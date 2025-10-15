#!/bin/bash

echo "🛑 Shutting down Shadow Access Detector..."

pkill -f "node app.js"         # Kill backend
pkill -f "react-scripts start" # Kill frontend

echo "✅ All processes terminated."
