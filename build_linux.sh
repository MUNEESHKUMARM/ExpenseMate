#!/bin/bash
set -e

echo "======================================="
echo " Building Linux Release Executable"
echo "======================================="

flutter clean
flutter pub get
flutter build linux --release

echo "[SUCCESS] Linux release build complete at build/linux/x64/release/bundle/"
