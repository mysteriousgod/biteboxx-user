import 'package:stackfood_multivendor/common/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showCustomSnackBar(String? message, {bool isError = true}) async {
  if(message != null && message.isNotEmpty) {

    try {
      if(Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
        // Add a small delay to allow the previous snackbar controller to dispose completely.
        // This fixes the LateInitializationError on Web.
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      Get.showSnackbar(GetSnackBar(
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 2),
        overlayBlur: 0.0,
        margin: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
        messageText: CustomToast(text: message, isError: isError),
        borderRadius: 10,
        padding: const EdgeInsets.all(0),
        snackStyle: SnackStyle.FLOATING,
        isDismissible: true,
        forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
        reverseAnimationCurve: Curves.fastEaseInToSlowEaseOut,
        animationDuration: const Duration(milliseconds: 500),
      ));
    } catch(e) {
      debugPrint('Failed to show snackbar: $e');
      // Ensure the user sees the message even if UI fails
      debugPrint('Snackbar Message ($isError): $message');
    }

  }
}