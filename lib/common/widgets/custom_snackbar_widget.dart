import 'package:stackfood_multivendor/common/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showCustomSnackBar(String? message, {bool isError = true}) async {
  if(message != null && message.isNotEmpty) {

    try {
      try {
        if(Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
          await Future.delayed(const Duration(milliseconds: 200));
        }
      } catch(e) {
        debugPrint('Failed to close existing snackbars: $e');
      }
      if (Get.context == null || Get.overlayContext == null) {
        debugPrint('Cannot show snackbar: No context/overlay available. Message: $message');
        return;
      }
      // Verify overlay exists first
      if (Get.overlayContext != null && Overlay.maybeOf(Get.overlayContext!) == null) {
         debugPrint('Overlay.maybeOf returned null. Trying ScaffoldMessenger fallback.');
         if (Get.context != null) {
             ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
                content: Text(message, style: const TextStyle(color: Colors.white)),
                backgroundColor: isError ? Colors.red : Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(10),
                duration: const Duration(seconds: 2),
             ));
         }
         return;
      }

      // Ensure we are not building during a build phase
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          // if(Get.isSnackbarOpen) {
          //   await Get.closeCurrentSnackbar(); 
          //   // Add a small delay for safety
          //   await Future.delayed(const Duration(milliseconds: 150));
          // }
          
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
        }
      });
    } catch(e) {
      debugPrint('Failed to show snackbar: $e');
      // Ensure the user sees the message even if UI fails
      debugPrint('Snackbar Message ($isError): $message');
    }

  }
}