import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/favourite/widgets/fav_item_view_widget.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BiteboxxModernFavouriteView extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onExploreRestaurants;

  const BiteboxxModernFavouriteView({
    super.key,
    required this.tabController,
    required this.onExploreRestaurants,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Container(
      color: isDark ? const Color(0xFF121214) : const Color(0xFFF7F8FA),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your favorites',
                    style: robotoBold.copyWith(
                      fontSize: 24,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Good food, saved for later',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: GetBuilder<FavouriteController>(
                builder: (favController) {
                  final bool hasWishItem = favController.wishProductList != null && favController.wishProductList!.isNotEmpty;
                  final bool hasWishRest = favController.wishRestList != null && favController.wishRestList!.isNotEmpty;
                  final bool hasFavourites = isLoggedIn && (hasWishItem || hasWishRest);

                  if (!hasFavourites) {
                    // Empty State Card Matching Image 3
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                        decoration: ThemeTokens.modernCardBox(radius: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Peach Rounded Square with Orange Heart Icon
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0E6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.favorite_border_rounded,
                                  color: Color(0xFFFF6000),
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Keep your go-to spots close',
                              style: robotoBold.copyWith(
                                fontSize: 18,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                              'Tap the heart on a restaurant to save it here for your next meal.',
                              textAlign: TextAlign.center,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: const Color(0xFF6B7280),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Orange Pill Button
                            InkWell(
                              onTap: onExploreRestaurants,
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6000),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6000).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Explore restaurants',
                                    style: robotoBold.copyWith(
                                      color: Colors.white,
                                      fontSize: Dimensions.fontSizeDefault,
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

                  // If user has favourites, show tab bar view
                  return Column(
                    children: [
                      TabBar(
                        controller: tabController,
                        indicatorColor: const Color(0xFFFF6000),
                        indicatorWeight: 3,
                        labelColor: const Color(0xFFFF6000),
                        unselectedLabelColor: Colors.grey,
                        labelStyle: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                        tabs: [
                          Tab(text: 'food'.tr),
                          Tab(text: 'restaurants'.tr),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: const [
                            FavItemViewWidget(isRestaurant: false),
                            FavItemViewWidget(isRestaurant: true),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

