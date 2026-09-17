@echo off
echo =======================================
echo  Building Android Release APK
echo =======================================
call flutter clean
call flutter pub get
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Android APK build failed!
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] Android APK built at build\app\outputs\flutter-apk\app-release.apk
