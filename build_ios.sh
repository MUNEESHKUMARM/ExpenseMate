#!/bin/bash
set -e

echo "======================================="
echo " Building Unsigned iOS Release IPA/App"
echo "======================================="

flutter clean
flutter pub get
flutter build ios --release --no-codesign

echo "[SUCCESS] Unsigned iOS release build complete at build/ios/iphoneos/"
