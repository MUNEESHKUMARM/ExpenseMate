@echo off
echo =======================================
echo  Building Web Release Bundle
echo =======================================
call flutter clean
call flutter pub get
call flutter build web --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Web release build failed!
    exit /b %ERRORLEVEL%
)
echo [SUCCESS] Web release bundle built at build\web\
