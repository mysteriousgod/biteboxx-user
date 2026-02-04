@echo off
echo Generating keystore for release APK build...

echo Creating keystore directory...
mkdir android\app\keystore 2>nul

echo Generating keystore file...
keytool -genkey -v -keystore android\app\keystore\keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias bitebox_user -storepass @Anilch133 -keypass @Anilch133

if %ERRORLEVEL% == 0 (
    echo.
    echo Keystore generated successfully!
    echo You can now build release APK using:
    echo flutter build apk --release --dart-define=API_BASE_URL=https://main.d1wk7b6t2z78p1.amplifyapp.com
    echo.
    echo Or run: build_apk.bat
) else (
    echo.
    echo Failed to generate keystore. Make sure Java JDK is installed and in PATH.
    echo You can still use the debug APK for testing.
    echo.
)

pause