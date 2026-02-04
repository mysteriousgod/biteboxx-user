# Building Your Flutter APK with AWS Amplify API URL

## Current Configuration
Your app is configured to use the API URL: `https://main.d1wk7b6t2z78p1.amplifyapp.com`

## Build Scripts

### Windows
Run: `build_apk.bat`

### Linux/Mac
Run: `./build_apk.sh`

## Keystore Information

The build configuration looks for a keystore file at:
`android/app/keystore/keystore.jks`

### If keystore exists:
- Builds signed release APK (ready for Google Play Store)

### If keystore doesn't exist:
- Builds debug APK (for development/testing only)

## Generating a Keystore (Required for Release APK)

If you need to create a release-ready APK, you have two options:

### Option 1: Use the automated script (Windows)
Run: `generate_keystore.bat`

This will create the keystore with the correct passwords and alias.

### Option 2: Manual generation
Generate a keystore using the keytool command:

```bash
keytool -genkey -v -keystore android/app/keystore/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias bitebox_user
```

### Password Information
The build configuration expects:
- Store password: `@Anilch133`
- Key password: `@Anilch133`
- Alias: `bitebox_user`

The passwords are already configured in `android/app/build.gradle`.

## Important Note About API URL

⚠️ **Warning**: `https://main.d1wk7b6t2z78p1.amplifyapp.com` is a **frontend web hosting URL** from AWS Amplify Console. This serves your Flutter web app, not API endpoints. Using it as an API URL may cause your app to fail because:

- Amplify Console hosts static web files, not backend APIs
- API requests may return HTML instead of JSON responses
- Your app expects API endpoints to return JSON data

## For Proper Backend API Functionality

Consider deploying your backend API separately using:
- AWS Lambda + API Gateway
- AWS EC2 instances
- AWS Elastic Beanstalk
- Other backend services

## APK Locations

- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Split APKs**: `build/app/outputs/flutter-apk/` (multiple files for different architectures)

## Build Command Reference

```bash
# Debug build
flutter build apk --debug --dart-define=API_BASE_URL=https://main.d1wk7b6t2z78p1.amplifyapp.com

# Release build (requires keystore)
flutter build apk --release --dart-define=API_BASE_URL=https://main.d1wk7b6t2z78p1.amplifyapp.com

# Split APKs (requires keystore)
flutter build apk --split-per-abi --release --dart-define=API_BASE_URL=https://main.d1wk7b6t2z78p1.amplifyapp.com