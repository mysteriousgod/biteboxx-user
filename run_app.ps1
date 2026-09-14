Set-Location $PSScriptRoot

Write-Host "Checking for running Android emulator..." -ForegroundColor Cyan

$devices = adb devices
$emulatorRunning = $devices | Select-String "emulator-"

if (-not $emulatorRunning) {
    # Discover available AVDs from Android Studio
    $avdList = & "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -list-avds 2>$null
    $chosenAvd = if ($avdList -contains "Medium_Phone") { "Medium_Phone" } elseif ($avdList -contains "TestEmulator") { "TestEmulator" } elseif ($avdList) { $avdList[0] } else { "Medium_Phone" }

    Write-Host "Starting Android Studio Emulator ($chosenAvd) on your desktop..." -ForegroundColor Yellow
    Start-Process "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -ArgumentList "-avd", $chosenAvd
    Write-Host "Waiting for emulator to boot up..." -ForegroundColor Yellow
    adb wait-for-device
    Start-Sleep -Seconds 3
    Write-Host "Emulator connected successfully!" -ForegroundColor Green
} else {
    Write-Host "Emulator is already running!" -ForegroundColor Green
}

Write-Host "Launching Flutter App..." -ForegroundColor Cyan
flutter run -d emulator-5554
