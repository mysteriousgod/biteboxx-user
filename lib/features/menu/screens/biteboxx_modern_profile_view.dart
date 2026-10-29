import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BiteboxxModernProfileView extends StatelessWidget {
  final VoidCallback onOrdersTap;

  const BiteboxxModernProfileView({
    super.key,
    required this.onOrdersTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Container(
      color: isDark ? const Color(0xFF121214) : const Color(0xFFF7F8FA),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: GetBuilder<ProfileController>(
            builder: (profileController) {
              final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
              final String userName = isLoggedIn && profileController.userInfoModel != null
                  ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}'.trim()
                  : 'Guest user';
              final String phone = isLoggedIn && profileController.userInfoModel != null
                  ? (profileController.userInfoModel?.phone ?? '')
                  : '9015434712';
              final String initials = userName.isNotEmpty
                  ? (userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase())
                  : 'GU';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title
                  Text(
                    'My profile',
                    style: robotoBold.copyWith(
                      fontSize: 24,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your account, all in one place',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Profile Card (Matching Image 2) ─────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2E2018), Color(0xFF1E1E22)],
                            )
                          : const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFE5D0),
                                Color(0xFFFFF2E8),
                                Color(0xFFFFFFFF),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6000).withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Circular Avatar with White Border
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: isLoggedIn && profileController.userInfoModel?.imageFullUrl != null
                                    ? CustomImageWidget(
                                        image: profileController.userInfoModel!.imageFullUrl!,
                                        height: 62,
                                        width: 62,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          initials,
                                          style: robotoBold.copyWith(
                                            color: const Color(0xFFFF6000),
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Name + Phone
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: robotoBold.copyWith(
                                      fontSize: 18,
                                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    phone,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Inset Pill: [ Edit profile > ]
                        InkWell(
                          onTap: () {
                            if (isLoggedIn) {
                              Get.toNamed(RouteHelper.getProfileRoute());
                            } else {
                              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                            }
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFFF6000)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isLoggedIn ? 'Edit profile' : 'Sign in / Edit profile',
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFFF6000)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Account Section (2-Column Grid) ────────────────────────
                  Text(
                    'Account',
                    style: robotoBold.copyWith(
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Card 1: Your orders
                      Expanded(
                        child: InkWell(
                          onTap: onOrdersTap,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: ThemeTokens.modernCardBox(radius: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFF0E6),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.receipt_long_rounded, color: Color(0xFFFF6000), size: 20),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Your orders',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Track & reorder',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Card 2: Help & support
                      Expanded(
                        child: InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: ThemeTokens.modernCardBox(radius: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFF0E6),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.support_agent_rounded, color: Color(0xFFFF6000), size: 20),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Help & support',
                                  style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "We're here to help",
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraSmall,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── About & Policies Section ────────────────────────────────
                  Text(
                    'About & policies',
                    style: robotoBold.copyWith(
                      fontSize: 16,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: ThemeTokens.modernCardBox(radius: 20),
                    child: Column(
                      children: [
                        _buildPolicyItem(
                          icon: Icons.info_outline_rounded,
                          title: 'About us',
                          onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('about-us')),
                          showDivider: true,
                          isDark: isDark,
                        ),
                        _buildPolicyItem(
                          icon: Icons.shield_outlined,
                          title: 'Privacy policy',
                          onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('privacy-policy')),
                          showDivider: true,
                          isDark: isDark,
                        ),
                        _buildPolicyItem(
                          icon: Icons.gavel_rounded,
                          title: 'Terms & conditions',
                          onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('terms-and-condition')),
                          showDivider: true,
                          isDark: isDark,
                        ),
                        _buildPolicyItem(
                          icon: Icons.sync_alt_rounded,
                          title: 'Refunds & returns',
                          onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('refund-policy')),
                          showDivider: true,
                          isDark: isDark,
                        ),
                        _buildPolicyItem(
                          icon: Icons.local_shipping_outlined,
                          title: 'Shipping policy',
                          onTap: () => Get.toNamed(RouteHelper.getHtmlRoute('shipping-policy')),
                          showDivider: false,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
    required bool isDark,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF0E6),
                  ),
                  child: Center(
                    child: Icon(icon, color: const Color(0xFFFF6000), size: 16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: isDark ? Colors.white : const Color(0xFF374151),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9CA3AF)),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 62,
            endIndent: 16,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF3F4F6),
          ),
      ],
    );
  }
}
