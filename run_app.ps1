Write-Host "Checking for running Android emulator..." -ForegroundColor Cyan

$devices = adb devices
$emulatorRunning = $devices | Select-String "emulator-"

if (-not $emulatorRunning) {
    Write-Host "Starting TestEmulator window on your desktop..." -ForegroundColor Yellow
    Start-Process "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd", "TestEmulator"
    Write-Host "Waiting for emulator to boot up..." -ForegroundColor Yellow
    adb wait-for-device
    Start-Sleep -Seconds 3
    Write-Host "Emulator connected successfully!" -ForegroundColor Green
} else {
    Write-Host "Emulator is already running!" -ForegroundColor Green
}

Write-Host "Launching Flutter App..." -ForegroundColor Cyan
flutter run -d emulator-5554
