# Firebase Phone/SMS Authentication Setup Guide

This document explains how to properly configure Firebase Phone Authentication for the Bite Boxxer app to avoid "suspicious activity" / "unusual activity" errors.

---

## 🔥 Common Causes of "Suspicious Activity" Errors

1. **Missing SHA-1/SHA-256 fingerprints** in Firebase Console
2. **App verification (SafetyNet/Play Integrity)** not configured
3. **Too many requests** from the same device/IP without throttling
4. **Test phone numbers** not configured for development
5. **Incorrect `google-services.json`** (missing `oauth_client` entries)

---

## ✅ Step 1: Add SHA-1 and SHA-256 Fingerprints to Firebase

This is the **most critical step**. Without SHA fingerprints, Firebase cannot verify your app and will block phone auth requests.

### Get Debug SHA-1 (for development)

```bash
# On macOS/Linux:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# On Windows:
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### Get Release SHA-1 (for production)

```bash
keytool -list -v -keystore android/app/keystore/keystore.jks -alias bitebox_user
# Enter the keystore password when prompted
```

### Add to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/) → Project **biteboxx-82e93**
2. Click ⚙️ **Project Settings** → **General** tab
3. Scroll to **Your apps** → Select the Android app (`com.biteboxer.user`)
4. Click **Add fingerprint**
5. Add **both** SHA-1 and SHA-256 for:
   - Debug keystore (for development/testing)
   - Release keystore (for production builds)
6. **Download the updated `google-services.json`** and replace `android/app/google-services.json`

> ⚠️ **Important**: The current `google-services.json` has empty `oauth_client` arrays, which confirms SHA fingerprints are missing. After adding them, the downloaded file will include `oauth_client` entries.

---

## ✅ Step 2: Enable Phone Authentication in Firebase

1. Go to Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Phone** provider
3. Save

---

## ✅ Step 3: Configure Test Phone Numbers (for Development)

To avoid hitting SMS quotas and rate limits during development:

1. Go to Firebase Console → **Authentication** → **Sign-in method** → **Phone**
2. Under **Phone numbers for testing**, add test numbers:

| Phone Number | Verification Code |
|---|---|
| `+1 650-555-1234` | `123456` |
| `+91 9999999999` | `123456` |
| `+1 555-555-0100` | `654321` |

> Add any phone numbers your team uses for testing. These numbers will:
> - **Not** send real SMS messages
> - **Not** count toward your SMS quota
> - **Not** trigger rate limiting
> - Always accept the configured verification code

---

## ✅ Step 4: Configure Android App Verification

### Option A: SafetyNet / Play Integrity (Recommended for Production)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project **biteboxx-82e93**
3. Enable **Android Device Verification API**
4. The API key in `google-services.json` (`AIzaSyC2ztNxIqRZKJhCqbfgmwCpte3KqlgGdrg`) must have this API enabled

### Option B: reCAPTCHA Fallback (Automatic)

Firebase automatically falls back to reCAPTCHA verification if SafetyNet/Play Integrity is unavailable. No additional configuration needed, but ensure:
- The SHA-1 fingerprints are correctly added (Step 1)
- The API key has no restrictions that block reCAPTCHA

---

## ✅ Step 5: Verify `google-services.json`

After adding SHA fingerprints, download a fresh `google-services.json` from Firebase Console and verify it contains:

```json
{
  "client": [
    {
      "client_info": {
        "android_client_info": {
          "package_name": "com.biteboxer.user"
        }
      },
      "oauth_client": [
        {
          "client_id": "xxxxx.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.biteboxer.user",
            "certificate_hash": "YOUR_SHA1_HERE"
          }
        }
      ]
    }
  ]
}
```

If `oauth_client` is still empty `[]`, the SHA fingerprints were not added correctly.

---

## ✅ Step 6: Firebase Auth Emulator (Optional, for Local Development)

For completely offline testing without any SMS costs:

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Initialize: `firebase init emulators`
3. Start emulator: `firebase emulators:start --only auth`
4. In your Flutter app, connect to the emulator before any auth calls:

```dart
// In main.dart or initialization code (DEBUG only):
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}
```

---

## 🔧 Error Handling Reference

The app now handles these Firebase Phone Auth error codes with user-friendly messages:

| Error Code | User Message |
|---|---|
| `invalid-phone-number` | Please submit a valid phone number |
| `too-many-requests` | Too many attempts. Please try again after a few minutes. |
| `quota-exceeded` | SMS limit reached. Please try again later. |
| `app-not-authorized` | This app is not authorized for phone authentication. |
| `captcha-check-failed` | Verification failed. Please try again. |
| `missing-client-identifier` | App verification failed. Please reinstall the app. |
| `network-request-failed` | Network error. Please check your internet connection. |
| `user-disabled` | This account has been disabled. |
| `session-expired` | Verification code has expired. Please request a new one. |
| `invalid-verification-code` | Invalid verification code. Please check and try again. |

---

## 🔄 Rate Limiting & Cooldown

The app implements:
- **30-second cooldown** between OTP requests to prevent rapid-fire requests
- **`forceResendingToken`** support — reuses Firebase's resend token to avoid being flagged as a new device
- **User-facing countdown** on the verification screen (60 seconds)

---

## 📋 Quick Checklist

- [ ] SHA-1 (debug) added to Firebase Console
- [ ] SHA-1 (release) added to Firebase Console
- [ ] SHA-256 (debug) added to Firebase Console
- [ ] SHA-256 (release) added to Firebase Console
- [ ] Fresh `google-services.json` downloaded and placed in `android/app/`
- [ ] Phone provider enabled in Firebase Authentication
- [ ] Test phone numbers added for development
- [ ] Android Device Verification API enabled in Google Cloud Console
- [ ] App builds and runs without "suspicious activity" errors
