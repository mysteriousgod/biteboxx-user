import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/countdown/controllers/countdown_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/images.dart';

class CountdownView extends StatefulWidget {
  const CountdownView({super.key});

  @override
  State<CountdownView> createState() => _CountdownViewState();
}

class _CountdownViewState extends State<CountdownView> {
  Timer? _launchTimer;

  @override
  void initState() {
    super.initState();
    _checkForLaunch();
  }

  @override
  void dispose() {
    _launchTimer?.cancel();
    super.dispose();
  }

  void _checkForLaunch() {
    final controller = Get.find<CountdownController>();
    
    // If already launched, navigate immediately
    if (controller.isLaunched.value && mounted) {
      _navigateAfterLaunch();
      return;
    }

    // Check every 5 seconds if launch has occurred
    _launchTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (controller.isLaunched.value && mounted) {
        timer.cancel();
        _navigateAfterLaunch();
      }
    });
  }

  void _navigateAfterLaunch() {
    if (!mounted) return;
    
    // Navigate to initial route and clear countdown screen
    Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CountdownController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        // Don't show anything if launched - navigation will handle it
        if (controller.isLaunched.value) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        return Scaffold(
          body: _buildCountdownView(controller),
        );
      },
    );
  }

  Widget _buildCountdownView(CountdownController controller) {
    return Stack(
      children: [
        // Cinematic Animated Background exactly like a video loop
        const CinematicBackground(imageAsset: 'assets/image/premium_food_bg.png'),

        // Dark Overlay for Contrast
        Container(
          color: Colors.black.withOpacity(0.55),
        ),

        // Foreground Content
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    Images.logo,
                    height: 120, // Adjust height as necessary to make it prominent
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.restaurant_menu,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'BiteBoxx',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Subtitle
                  Text(
                    controller.countdownModel.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 1.2,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Countdown Timer
                  _buildCountdownTimer(controller),

                  const SizedBox(height: 60),

                  // Launch date
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Coming on ${controller.countdownModel.launchDate.day} April, ${controller.countdownModel.launchDate.year} at 12:00 PM',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownTimer(CountdownController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust width based on screen size for responsiveness
        double boxSize = constraints.maxWidth < 400 ? 70 : 90;
        double fontSize = constraints.maxWidth < 400 ? 28 : 38;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGlassTimeBox(controller.formattedDays, 'Days', boxSize, fontSize),
            const SizedBox(width: 15),
            _buildGlassTimeBox(controller.formattedHours, 'Hours', boxSize, fontSize),
            const SizedBox(width: 15),
            _buildGlassTimeBox(controller.formattedMinutes, 'Minutes', boxSize, fontSize),
            const SizedBox(width: 15),
            _buildGlassTimeBox(controller.formattedSeconds, 'Seconds', boxSize, fontSize),
          ],
        );
      }
    );
  }

  Widget _buildGlassTimeBox(String value, String label, double size, double fontSize) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: size,
              height: size * 1.1,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaunchedView() {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          children: [
            // Subtly blurred background for launched view
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset(
                  Images.logo,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF7918).withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.rocket_launch,
                            size: 80,
                            color: Color(0xFFFF7918),
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'We\'ve Launched!',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Thank you for your patience.\nBiteBoxx is now live!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            Get.offAllNamed('/home');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7918),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            elevation: 10,
                            shadowColor: const Color(0xFFFF7918).withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Enter BiteBoxx',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CinematicBackground extends StatefulWidget {
  final String imageAsset;
  const CinematicBackground({super.key, required this.imageAsset});

  @override
  State<CinematicBackground> createState() => _CinematicBackgroundState();
}

class _CinematicBackgroundState extends State<CinematicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.05, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    _alignAnimation = Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.bottomRight).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Align(
            alignment: _alignAnimation.value,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
