#!/bin/bash
# Run automatic dependency installation inside Claude VM

echo "[Claude Setup] Installing Node.js dependencies..."
if [ -f package.json ]; then
  npm install --legacy-peer-deps
fi

echo "[Claude Setup] Installing Python dependencies..."
if [ -f requirements.txt ]; then
  pip install -r requirements.txt
fi

echo "[Claude Setup] All dependencies installed successfully!"
exit 0
