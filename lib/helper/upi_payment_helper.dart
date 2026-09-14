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

  static const List<String> knownUpiSchemes = [
    'upi',
    'paytmmp',
    'paytm',
    'phonepe',
    'tez',
    'gpay',
    'bhim',
    'credpay',
    'mobikwik',
    'whatsapp',
  ];

  /// Checks if a given URL string or Uri represents an external UPI payment or Android Intent.
  static bool isUpiOrIntentUrl(String urlString, [Uri? uri]) {
    final lower = urlString.toLowerCase().trim();
    if (lower.startsWith('intent://') || lower.startsWith('intent:#intent')) {
      return true;
    }
    final scheme = (uri?.scheme.isNotEmpty == true ? uri!.scheme : Uri.tryParse(urlString)?.scheme)?.toLowerCase();
    if (scheme != null && scheme.isNotEmpty) {
      if (knownUpiSchemes.contains(scheme)) {
        return true;
      }
      if (!standardWebSchemes.contains(scheme)) {
        return true;
      }
    }
    return false;
  }

  /// Parses Android intent or custom UPI scheme and launches the appropriate UPI app.
  /// Returns `true` if an external application or fallback was successfully triggered.
  static Future<bool> launchUpiPayment(String urlString) async {
    try {
      if (kDebugMode) {
        print('UPI/Intent processing: $urlString');
      }

      String targetUrl = urlString;
      String? targetPackage;
      String? fallbackUrl;

      // Case 1: Intent URI (Chrome intent syntax: intent://... or intent:#Intent...)
      if (urlString.startsWith('intent://') || urlString.startsWith('intent:#Intent')) {
        // Extract fallback URL if present
        final fallbackMatch = RegExp(r'browser_fallback_url=([^;]+)').firstMatch(urlString);
        if (fallbackMatch != null) {
          fallbackUrl = Uri.decodeComponent(fallbackMatch.group(1)!);
        }

        // Extract package if specified
        final pkgMatch = RegExp(r'package=([^;]+);?').firstMatch(urlString);
        if (pkgMatch != null) {
          targetPackage = pkgMatch.group(1);
        }

        if (urlString.startsWith('intent://')) {
          final schemeMatch = RegExp(r'scheme=([a-zA-Z0-9_-]+);?').firstMatch(urlString);
          final scheme = schemeMatch?.group(1) ?? 'upi';
          final pathWithQuery = urlString.substring('intent://'.length).split('#Intent')[0];
          targetUrl = '$scheme://$pathWithQuery';
        } else if (urlString.startsWith('intent:#Intent')) {
          final dataMatch = RegExp(r'data=([^;]+);?').firstMatch(urlString);
          if (dataMatch != null) {
            targetUrl = Uri.decodeComponent(dataMatch.group(1)!);
          }
        }
      }

      if (kDebugMode) {
        print('Parsed UPI target: $targetUrl, package: $targetPackage, fallback: $fallbackUrl');
      }

      // First attempt: try launching targetUrl directly
      final targetUri = Uri.tryParse(targetUrl);
      if (targetUri != null) {
        try {
          if (await canLaunchUrl(targetUri)) {
            final launched = await launchUrl(targetUri, mode: LaunchMode.externalApplication);
            if (launched) return true;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Direct launch failed for $targetUri: $e');
          }
        }

        // Secondary attempt: if direct launch returned false, try force-launching with externalApplication
        try {
          final launched = await launchUrl(targetUri, mode: LaunchMode.externalApplication);
          if (launched) return true;
        } catch (_) {}
      }

      // Third attempt: if specific scheme (like paytmmp / tez / phonepe) failed, convert to generic upi://
      if (!targetUrl.startsWith('upi://') && targetUrl.contains('?')) {
        final queryIndex = targetUrl.indexOf('?');
        final genericUpiUrl = 'upi://pay${targetUrl.substring(queryIndex)}';
        final genericUri = Uri.tryParse(genericUpiUrl);
        if (genericUri != null) {
          try {
            if (await canLaunchUrl(genericUri)) {
              final launched = await launchUrl(genericUri, mode: LaunchMode.externalApplication);
              if (launched) return true;
            }
          } catch (_) {}
        }
      }

      // Fourth attempt: browser fallback URL
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
