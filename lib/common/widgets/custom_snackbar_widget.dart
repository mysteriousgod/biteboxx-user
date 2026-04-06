import 'package:stackfood_multivendor/common/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showCustomSnackBar(String? message, {bool isError = true}) async {
  if (message == null || message.isEmpty) return;

  try {
    // Fix #1: wrap closeAllSnackbars in try/catch — it crashes if
    // SnackbarController._controller was never initialized
    try {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('Failed to close existing snackbars: $e');
    }

    // Fix #2: use Get.overlayContext instead of Get.context, and look
    // up the overlay from the root navigator key to guarantee it exists
    final BuildContext? ctx = Get.overlayContext ?? Get.context;
    if (ctx == null) {
      debugPrint('No context available for snackbar: $message');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        // Walk up from overlayContext — this always finds the top-level Overlay
        // inserted by MaterialApp/Navigator, never the bottom-sheet's Navigator
        OverlayState? overlay;

        // Try rootNavigator overlay first (most reliable)
        final NavigatorState? navigator =
            Navigator.maybeOf(ctx, rootNavigator: true);
        if (navigator != null) {
          overlay = navigator.overlay;
        }

        // Fallback to nearest overlay
        overlay ??= Overlay.maybeOf(ctx);

        if (overlay == null) {
          debugPrint('No overlay found, falling back to ScaffoldMessenger');
          if (Get.context != null) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
              content:
                  Text(message, style: const TextStyle(color: Colors.white)),
              backgroundColor: isError ? Colors.red : Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(10),
              duration: const Duration(seconds: 2),
            ));
          }
          return;
        }

        late OverlayEntry entry;
        entry = OverlayEntry(
          builder: (overlayCtx) => Positioned(
            // Respects status bar height on all devices
            top: MediaQuery.of(overlayCtx).padding.top + 10,
            left: 20,
            right: 20,
            child: _TopSnackBar(
              message: message,
              isError: isError,
              onDismiss: () {
                try {
                  entry.remove();
                } catch (_) {}
              },
            ),
          ),
        );

        overlay.insert(entry);

        // Safety removal after 3s in case animation callback is missed
        Future.delayed(const Duration(milliseconds: 3000), () {
          try {
            entry.remove();
          } catch (_) {}
        });
      } catch (e) {
        debugPrint('Failed to show snackbar overlay: $e');
      }
    });
  } catch (e) {
    debugPrint('Failed to show snackbar: $e');
  }
}

class _TopSnackBar extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _TopSnackBar({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    ));

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Begin slide-out before the safety removal fires
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: widget.onDismiss,
            // Reuses your existing CustomToast widget unchanged
            child: CustomToast(text: widget.message, isError: widget.isError),
          ),
        ),
      ),
    );
  }
}
