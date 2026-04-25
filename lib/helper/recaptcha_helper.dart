import 'package:flutter/foundation.dart';

/// Helper class for reCAPTCHA integration with Firebase Phone Auth.
///
/// Firebase Auth handles reCAPTCHA automatically on all platforms:
/// - **Web**: Firebase Auth web SDK shows an invisible reCAPTCHA v2 challenge
///   automatically when verifyPhoneNumber() is called.
/// - **iOS**: Firebase Auth uses invisible reCAPTCHA or App Attest internally.
/// - **Android**: Firebase Auth uses visible/invisible reCAPTCHA internally.
///
/// This helper provides utility methods for reCAPTCHA-related operations.
class RecaptchaHelper {
  /// Returns true if reCAPTCHA is handled automatically by Firebase Auth.
  /// This is always true since Firebase Auth manages reCAPTCHA internally.
  static bool get isAutomaticallyHandled => true;

  /// Logs reCAPTCHA status for debugging purposes.
  static void logStatus() {
    if (kIsWeb) {
      debugPrint('===== reCAPTCHA: Web platform - Firebase Auth will handle reCAPTCHA automatically =====');
      debugPrint('===== reCAPTCHA: Make sure your domain is authorized in Firebase Console =====');
    } else {
      debugPrint('===== reCAPTCHA: Mobile platform - Firebase Auth native SDK will handle reCAPTCHA =====');
    }
  }

  /// Provides troubleshooting tips for common reCAPTCHA issues.
  static String getTroubleshootingTips() {
    return '''
    If reCAPTCHA is not working, check:

    For Web:
    1. Add your domain to Authorized domains in Firebase Console > Authentication > Settings
    2. Make sure reCAPTCHA site key is configured in Firebase Console
    3. Clear browser cache and cookies
    4. Try incognito mode to rule out extension conflicts

    For iOS:
    1. Make sure Firebase/Auth pod is installed (run: cd ios && pod install)
    2. Add your Apple Bundle ID to Firebase Console
    3. Download and add GoogleService-Info.plist to your Xcode project
    4. Enable Associated Domains capability in Xcode
    5. Add applinks:your-project-id.web.app to Associated Domains

    For Android:
    1. Add SHA-1 and SHA-256 fingerprints in Firebase Console > Project Settings
    2. Download and add google-services.json to android/app/
    3. Make sure Google Sign-In is configured in build.gradle
    ''';
  }
}