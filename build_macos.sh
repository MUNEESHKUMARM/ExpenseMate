#!/bin/bash
set -e

echo "======================================="
echo " Building macOS Release App"
echo "======================================="

flutter clean
flutter pub get
flutter build macos --release

echo "[SUCCESS] macOS release build complete at build/macos/Build/Products/Release/"
