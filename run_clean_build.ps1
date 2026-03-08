
Write-Host "=== STARTING DEEP CLEAN & BUILD ===" -ForegroundColor Green

# 1. Kill potentially stuck processes
Write-Host "1. Killing stuck Java/Dart processes..."
taskkill /F /IM java.exe 2>$null
taskkill /F /IM dart.exe 2>$null
taskkill /F /IM flutter.exe 2>$null
taskkill /F /IM adb.exe 2>$null

# 2. Add safe delay
Start-Sleep -Seconds 2

# 3. Force delete build directory
Write-Host "2. Deleting build directory..."
if (Test-Path "build") {
    Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
}
if (Test-Path ".dart_tool") {
    Remove-Item -Recurse -Force ".dart_tool" -ErrorAction SilentlyContinue
}

# 4. Clean Gradle
Write-Host "3. Cleaning Gradle..."
cd android
./gradlew clean
cd ..

# 5. Flutter Clean
Write-Host "4. Running flutter clean..."
flutter clean

# 6. Flutter Pub Get
Write-Host "5. Getting dependencies..."
flutter pub get

# 7. Build Release APK
Write-Host "6. Building Release APK (This may take a few minutes)..." -ForegroundColor Yellow
flutter build apk --release

Write-Host "=== BUILD COMPLETE ===" -ForegroundColor Green
Write-Host "New APK is at: build/app/outputs/flutter-apk/app-release.apk" -ForegroundColor Green
