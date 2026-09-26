import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiPaymentHelper {
  static const List<String> standardWebSchemes = [
    'http',
    'https',
    'file',
    'chrome',
    'data',
    'javascript',
    'about',
  ];

  static final Map<String, String> packageToScheme = {
    'com.phonepe.app': 'phonepe',
    'net.one97.paytm': 'paytmmp',
    'com.google.android.apps.nbu.paisa.user': 'tez',
    'com.dreamplug.androidapp': 'credpay',
    'in.amazon.mShop.android.shopping': 'amazonpay',
    'com.whatsapp': 'whatsapp',
    'com.mobikwik_new': 'mobikwik',
  };

  /// Returns true if the URL represents a UPI deep link, Android intent, or non-web custom scheme
  static bool isUpiOrIntentUrl(String url, [Uri? uri]) {
    final parsed = uri ?? Uri.tryParse(url);
    if (parsed == null) return false;
    final scheme = parsed.scheme.toLowerCase();
    if (scheme.isEmpty) return false;
    if (standardWebSchemes.contains(scheme)) {
      return false;
    }
    return true;
  }

  /// Builds a direct app-specific UPI URI if package is known
  static String? buildAppSpecificUpiUrl(String? targetPackage, String query) {
    if (targetPackage == null || !packageToScheme.containsKey(targetPackage)) {
      return null;
    }
    final scheme = packageToScheme[targetPackage]!;
    if (scheme == 'tez') {
      return 'tez://upi/pay?$query';
    }
    return '$scheme://pay?$query';
  }

  /// Parses Android intent or custom UPI scheme and launches the appropriate UPI app.
  /// Returns `true` if an external application or fallback was successfully triggered.
  static Future<bool> launchUpiPayment(String urlString) async {
    try {
      if (kDebugMode) {
        print('UPI/Intent processing: $urlString');
      }

      String? targetPackage;
      String? fallbackUrl;
      String? scheme;
      String query = '';

      // Extract query parameters
      if (urlString.contains('?')) {
        final qPart = urlString.split('?')[1];
        query = qPart.split('#Intent')[0];
      }

      // Extract package if present
      final pkgMatch = RegExp(r'package=([^;]+);?').firstMatch(urlString);
      if (pkgMatch != null) {
        targetPackage = pkgMatch.group(1);
      }

      // Extract fallback URL if present
      final fallbackMatch = RegExp(r'browser_fallback_url=([^;]+)').firstMatch(urlString);
      if (fallbackMatch != null) {
        fallbackUrl = Uri.decodeComponent(fallbackMatch.group(1)!);
      }

      // Extract scheme
      final schemeMatch = RegExp(r'scheme=([a-zA-Z0-9_-]+);?').firstMatch(urlString);
      if (schemeMatch != null) {
        scheme = schemeMatch.group(1);
      } else {
        final parsed = Uri.tryParse(urlString);
        if (parsed != null && parsed.scheme.isNotEmpty && parsed.scheme != 'intent') {
          scheme = parsed.scheme;
        }
      }

      if (kDebugMode) {
        print('Parsed package: $targetPackage, scheme: $scheme, query: $query');
      }

      List<String> urlsToTry = [];

      // 1. If a specific package was targeted (e.g. com.phonepe.app, net.one97.paytm, com.google.android.apps.nbu.paisa.user),
      // build that app's dedicated direct URI so Android launches that exact app, NOT another default app!
      if (targetPackage != null && query.isNotEmpty) {
        final directAppUrl = buildAppSpecificUpiUrl(targetPackage, query);
        if (directAppUrl != null) {
          urlsToTry.add(directAppUrl);
        }
      }

      // 2. If the scheme itself is an app-specific scheme (e.g. phonepe://, paytmmp://, tez://)
      if (scheme != null && scheme != 'upi' && scheme != 'intent' && query.isNotEmpty) {
        if (scheme == 'tez') {
          urlsToTry.add('tez://upi/pay?$query');
        } else {
          urlsToTry.add('$scheme://pay?$query');
        }
      }

      // 3. Generic NPCI UPI URL (upi://pay?...) - allows system chooser if dedicated app not installed
      if (query.isNotEmpty) {
        urlsToTry.add('upi://pay?$query');
      }

      // 4. Clean normalized original URL if distinct
      String normalized = urlString.trim();
      if (normalized.startsWith('intent://')) {
        String pathWithQuery = normalized.substring('intent://'.length).split('#Intent')[0];
        while (pathWithQuery.startsWith('/')) {
          pathWithQuery = pathWithQuery.substring(1);
        }
        if (pathWithQuery.startsWith('upi/')) {
          pathWithQuery = pathWithQuery.substring('upi/'.length);
        }
        if (!pathWithQuery.startsWith('pay') && pathWithQuery.contains('?')) {
          pathWithQuery = 'pay${pathWithQuery.substring(pathWithQuery.indexOf('?'))}';
        }
        normalized = 'upi://$pathWithQuery';
      }
      if (!urlsToTry.contains(normalized)) {
        urlsToTry.add(normalized);
      }

      // Attempt launching in priority order
      for (final candidate in urlsToTry) {
        final uri = Uri.tryParse(candidate);
        if (uri == null) continue;

        try {
          if (await canLaunchUrl(uri)) {
            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
            if (launched) {
              if (kDebugMode) {
                print('Successfully launched UPI URL: $candidate');
              }
              return true;
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('canLaunchUrl error for $candidate: $e');
          }
        }

        // Secondary attempt for Android 11+ package visibility: try direct launch
        try {
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (launched) {
            if (kDebugMode) {
              print('Successfully launched via direct fallback: $candidate');
            }
            return true;
          }
        } catch (_) {}
      }

      // Fallback URL (browser checkout)
      if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
        final fallbackUri = Uri.tryParse(fallbackUrl);
        if (fallbackUri != null && await canLaunchUrl(fallbackUri)) {
          return await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error handling UPI intent: $e');
      }
      return false;
    }
  }
}
