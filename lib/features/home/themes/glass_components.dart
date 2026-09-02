import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/product_model.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/discount_tag_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_available_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/features/cuisine/controllers/cuisine_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/home_controller.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/features/product/controllers/campaign_controller.dart';
import 'package:stackfood_multivendor/features/product/controllers/product_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

/// Ambient mesh aurora background that creates realistic refraction for frosted glass
class GlassAuroraBackground extends StatelessWidget {
  final Widget child;
  const GlassAuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    return Stack(
      children: [
        // Base canvas gradient with warm brand undertones
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0C0D10),
                        const Color(0xFF141210),
                        const Color(0xFF191410),
                        const Color(0xFF0D0E11),
                      ]
                    : [
                        const Color(0xFFFAF7F4),
                        const Color(0xFFFFF4EC),
                        const Color(0xFFFDF0E5),
                        const Color(0xFFF6F3EE),
                      ],
              ),
            ),
          ),
        ),

        // Glowing Orb 1: BiteBoxx Signature Brand Orange (Top-Right)
        Positioned(
          top: -40,
          right: -30,
          width: 330,
          height: 330,
          child: _buildGlowOrb(
            color: const Color(0xFFFF7918),
            opacity: isDark ? 0.38 : 0.28,
          ),
        ),

        // Glowing Orb 2: Golden Amber / Honey Glow (Center-Left)
        Positioned(
          top: 360,
          left: -60,
          width: 300,
          height: 300,
          child: _buildGlowOrb(
            color: const Color(0xFFFFA000),
            opacity: isDark ? 0.32 : 0.22,
          ),
        ),

        // Glowing Orb 3: Radiant Sunset Coral (Mid-Right)
        Positioned(
          top: 780,
          right: -40,
          width: 310,
          height: 310,
          child: _buildGlowOrb(
            color: const Color(0xFFFF5722),
            opacity: isDark ? 0.30 : 0.20,
          ),
        ),

        // Glowing Orb 4: Warm Tangerine Glow (Bottom-Left)
        Positioned(
          top: 1250,
          left: -50,
          width: 290,
          height: 290,
          child: _buildGlowOrb(
            color: const Color(0xFFFFB300),
            opacity: isDark ? 0.26 : 0.18,
          ),
        ),

        // Ambient diffusion blur filter over the orbs
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: const SizedBox.expand(),
          ),
        ),

        // Screen content with frosted glass cards
        child,
      ],
    );
  }

  Widget _buildGlowOrb({required Color color, required double opacity}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.4),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

/// Glassmorphic Hero Banner Carousel
class GlassBannerView extends StatelessWidget {
  const GlassBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeController) {
      List<String?>? bannerList = homeController.bannerImageList;
      List<dynamic>? bannerDataList = homeController.bannerDataList;

      if (bannerList == null || bannerList.isEmpty) {
        return const SizedBox();
      }

      final List<String?> displayBanners = bannerList;

      return Container(
        width: MediaQuery.of(context).size.width,
        height: ResponsiveHelper.isDesktop(context) ? 360 : MediaQuery.of(context).size.width * 0.48,
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
        child: Column(
          children: [
            Expanded(
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  viewportFraction: 0.92,
                  autoPlayInterval: const Duration(seconds: 6),
                  onPageChanged: (index, reason) {
                    homeController.setCurrentIndex(index, true);
                  },
                ),
                itemCount: displayBanners.length,
                itemBuilder: (context, index, _) {
                  return InkWell(
                    onTap: () {
                      if (bannerDataList != null && index < bannerDataList.length) {
                        if (bannerDataList[index] is Product) {
                          Product? product = bannerDataList[index];
                          ResponsiveHelper.isMobile(context)
                              ? showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (con) => ProductBottomSheetWidget(product: product),
                                )
                              : showDialog(
                                  context: context,
                                  builder: (con) => Dialog(child: ProductBottomSheetWidget(product: product)),
                                );
                        } else if (bannerDataList[index] is Restaurant) {
                          Restaurant restaurant = bannerDataList[index];
                          Get.toNamed(
                            RouteHelper.getRestaurantRoute(restaurant.id),
                            arguments: RestaurantScreen(restaurant: restaurant),
                          );
                        }
                      }
                    },
                    child: GlassContainer(
                      radius: 20,
                      padding: const EdgeInsets.all(4),
                      blur: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CustomImageWidget(
                          image: '${displayBanners[index]}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Frosted glass indicator pill (Theme 1 style)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 5,
                  width: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    '${(homeController.currentIndex % displayBanners.length) + 1}/${displayBanners.length}',
                    style: robotoBold.copyWith(fontSize: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  height: 5,
                  width: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

/// Glassmorphic Category Carousel
class GlassCategorySection extends StatelessWidget {
  const GlassCategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      final categories = categoryController.categoryList;
      if (categories == null || categories.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'whats_on_your_mind'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeLarge + 1,
                      color: Get.isDarkMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: categories.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    itemCount: categories.length > 12 ? 12 : categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(cat.id, cat.name!)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GlassContainer(
                                radius: 24,
                                padding: const EdgeInsets.all(8),
                                blur: 14,
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: CustomImageWidget(
                                      image: '${cat.imageFullUrl}',
                                      height: 52,
                                      width: 52,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  cat.name ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoMedium.copyWith(
                                    fontSize: 11,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox(),
          ),
        ],
      );
    });
  }
}

/// Glassmorphic Item Campaign (Special Offers)
class GlassItemCampaignSection extends StatelessWidget {
  const GlassItemCampaignSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {
      final campaigns = campaignController.itemCampaignList;
      if (campaigns == null || campaigns.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ThemedSectionHeader(
            title: 'trending_food_offers'.tr,
            subtitle: 'Exclusive discounts tailored for you',
            onViewAll: () => Get.toNamed(RouteHelper.getItemCampaignRoute()),
          ),
          SizedBox(
            height: 180,
            child: campaigns.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    itemCount: campaigns.length > 10 ? 10 : campaigns.length,
                    itemBuilder: (context, index) {
                      final product = campaigns[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 14, bottom: 6),
                        child: InkWell(
                          onTap: () {
                            ResponsiveHelper.isMobile(context)
                                ? Get.bottomSheet(
                                    ProductBottomSheetWidget(product: product, isCampaign: true),
                                    backgroundColor: Colors.transparent,
                                    isScrollControlled: true,
                                  )
                                : Get.dialog(
                                    Dialog(child: ProductBottomSheetWidget(product: product, isCampaign: true)),
                                  );
                          },
                          child: GlassContainer(
                            radius: 18,
                            padding: const EdgeInsets.all(10),
                            blur: 14,
                            child: SizedBox(
                              width: 155,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CustomImageWidget(
                                          image: '${product.imageFullUrl}',
                                          height: 95,
                                          width: 155,
                                          fit: BoxFit.cover,
                                          isFood: true,
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: GlassPill(
                                          tintColor: Colors.redAccent,
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          child: Text(
                                            'OFFER',
                                            style: robotoBold.copyWith(fontSize: 9, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        PriceConverter.convertPrice(product.price),
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_rounded, size: 14, color: Theme.of(context).primaryColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox(),
          ),
        ],
      );
    });
  }
}

/// Glassmorphic Popular Foods Section
class GlassPopularFoodSection extends StatelessWidget {
  final bool isPopular;
  const GlassPopularFoodSection({super.key, required this.isPopular});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      return GetBuilder<ProductController>(builder: (productController) {
        final productList = isPopular
            ? productController.popularProductList
            : reviewController.reviewedProductList;

        if (productList == null || productList.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),
            ThemedSectionHeader(
              title: isPopular ? 'popular_foods_nearby'.tr : 'best_reviewed_food'.tr,
              subtitle: 'Hand-picked delicacies with rave reviews',
              onViewAll: () => Get.toNamed(RouteHelper.getPopularFoodRoute(isPopular)),
            ),
            SizedBox(
              height: 105,
              child: productList.isNotEmpty
                  ? ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      itemCount: productList.length > 10 ? 10 : productList.length,
                      itemBuilder: (context, index) {
                        final product = productList[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 14, bottom: 4),
                          child: InkWell(
                            onTap: () {
                              ResponsiveHelper.isMobile(context)
                                  ? Get.bottomSheet(
                                      ProductBottomSheetWidget(product: product, isCampaign: false),
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                    )
                                  : Get.dialog(
                                      Dialog(child: ProductBottomSheetWidget(product: product)),
                                    );
                            },
                            child: GlassContainer(
                              radius: 18,
                              padding: const EdgeInsets.all(8),
                              blur: 14,
                              child: SizedBox(
                                width: 260,
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CustomImageWidget(
                                        image: '${product.imageFullUrl}',
                                        height: 80,
                                        width: 80,
                                        fit: BoxFit.cover,
                                        isFood: true,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            product.name ?? '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                              const SizedBox(width: 2),
                                              Text(
                                                product.avgRating?.toStringAsFixed(1) ?? '0.0',
                                                style: robotoBold.copyWith(fontSize: 11),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '(${product.ratingCount ?? 0})',
                                                style: robotoRegular.copyWith(
                                                  fontSize: 10,
                                                  color: Theme.of(context).disabledColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                PriceConverter.convertPrice(product.price),
                                                style: robotoBold.copyWith(
                                                  fontSize: Dimensions.fontSizeSmall,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const SizedBox(),
            ),
          ],
        );
      });
    });
  }
}

/// Glassmorphic Popular & Latest Stores Section
class GlassPopularStoreSection extends StatelessWidget {
  final bool isPopular;
  final bool isRecentlyViewed;
  final bool isOrderAgainViewed;

  const GlassPopularStoreSection({
    super.key,
    required this.isPopular,
    this.isRecentlyViewed = false,
    this.isOrderAgainViewed = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      final restaurantList = isPopular
          ? restaurantController.popularRestaurantList
          : isRecentlyViewed
              ? restaurantController.recentlyViewedRestaurantList
              : isOrderAgainViewed
                  ? restaurantController.orderAgainRestaurantList
                  : restaurantController.latestRestaurantList;

      if (restaurantList == null || restaurantList.isEmpty) {
        return const SizedBox();
      }

      String title = isPopular
          ? 'popular_restaurants'.tr
          : isRecentlyViewed
              ? 'recently_viewed_restaurants'.tr
              : isOrderAgainViewed
                  ? 'order_again'.tr
                  : '${'new_on'.tr} ${AppConstants.appName}';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ThemedSectionHeader(
            title: title,
            subtitle: 'Premier dining spots and trending cuisines',
            onViewAll: () => Get.toNamed(RouteHelper.getAllRestaurantRoute(
              isPopular
                  ? 'popular'
                  : isRecentlyViewed
                      ? 'recently_viewed'
                      : isOrderAgainViewed
                          ? 'order_again'
                          : 'latest',
            )),
          ),
          SizedBox(
            height: 185,
            child: restaurantList.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    itemCount: restaurantList.length > 10 ? 10 : restaurantList.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurantList[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 14, bottom: 6),
                        child: InkWell(
                          onTap: () {
                            Get.toNamed(
                              RouteHelper.getRestaurantRoute(restaurant.id),
                              arguments: RestaurantScreen(restaurant: restaurant),
                            );
                          },
                          child: GlassContainer(
                            radius: 20,
                            padding: const EdgeInsets.all(8),
                            blur: 14,
                            child: SizedBox(
                              width: 210,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: CustomImageWidget(
                                          image: '${restaurant.coverPhotoFullUrl}',
                                          height: 100,
                                          width: 210,
                                          fit: BoxFit.cover,
                                          isRestaurant: true,
                                        ),
                                      ),
                                      // Glowing Star Rating Pill
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: GlassPill(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                                              const SizedBox(width: 3),
                                              Text(
                                                restaurant.avgRating?.toStringAsFixed(1) ?? '0.0',
                                                style: robotoBold.copyWith(fontSize: 10, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Favorite button
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GetBuilder<FavouriteController>(builder: (favController) {
                                          bool isFav = favController.wishRestIdList.contains(restaurant.id);
                                          return GlassIconButton(
                                            icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                            iconColor: isFav ? Colors.redAccent : Colors.white,
                                            size: 28,
                                            iconSize: 15,
                                            onTap: () {
                                              if (AuthHelper.isLoggedIn()) {
                                                isFav
                                                    ? favController.removeFromFavouriteList(restaurant.id, true)
                                                    : favController.addToFavouriteList(null, restaurant.id, true);
                                              } else {
                                                showCustomSnackBar('you_are_not_logged_in'.tr);
                                              }
                                            },
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    restaurant.name ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.schedule_rounded, size: 12, color: Theme.of(context).disabledColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${restaurant.deliveryTime ?? '25-35'} min',
                                            style: robotoRegular.copyWith(
                                              fontSize: 10,
                                              color: Theme.of(context).disabledColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (restaurant.freeDelivery ?? false)
                                        GlassPill(
                                          tintColor: Colors.teal,
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          child: Text(
                                            'FREE DELIVERY',
                                            style: robotoBold.copyWith(fontSize: 8, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox(),
          ),
        ],
      );
    });
  }
}

/// Glassmorphic Cuisines Grid / Chips
class GlassCuisineSection extends StatelessWidget {
  const GlassCuisineSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CuisineController>(builder: (cuisineController) {
      final cuisines = cuisineController.cuisineModel?.cuisines;
      if (cuisines == null || cuisines.isEmpty) {
        return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ThemedSectionHeader(
            title: 'cuisines'.tr,
            subtitle: 'Explore authentic global flavors',
            onViewAll: () => Get.toNamed(RouteHelper.getCuisineRoute()),
          ),
          SizedBox(
            height: 95,
            child: cuisines.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    itemCount: cuisines.length > 8 ? 8 : cuisines.length,
                    itemBuilder: (context, index) {
                      final cuisine = cuisines[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => Get.toNamed(
                            RouteHelper.getCuisineRestaurantRoute(cuisine.id, cuisine.name),
                          ),
                          child: Column(
                            children: [
                              GlassContainer(
                                radius: 22,
                                padding: const EdgeInsets.all(4),
                                blur: 12,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: CustomImageWidget(
                                    image: '${cuisine.imageFullUrl}',
                                    height: 52,
                                    width: 52,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 68,
                                child: Text(
                                  cuisine.name ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoMedium.copyWith(
                                    fontSize: 11,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox(),
          ),
        ],
      );
    });
  }
}

/// Custom Glassmorphic Restaurant Card for the main feed
class GlassRestaurantCard extends StatelessWidget {
  final Restaurant? restaurant;
  const GlassRestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    if (restaurant == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall + 2,
      ),
      child: InkWell(
        onTap: () {
          if (restaurant!.restaurantStatus == 1) {
            Get.toNamed(
              RouteHelper.getRestaurantRoute(restaurant!.id),
              arguments: RestaurantScreen(restaurant: restaurant),
            );
          } else {
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        },
        child: GlassContainer(
          radius: 22,
          padding: const EdgeInsets.all(10),
          blur: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual cover with badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomImageWidget(
                      image: '${restaurant!.coverPhotoFullUrl}',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      isRestaurant: true,
                    ),
                  ),
                  // Rating Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: GlassPill(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            restaurant!.avgRating?.toStringAsFixed(1) ?? '0.0',
                            style: robotoBold.copyWith(fontSize: 11, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${restaurant!.ratingCount ?? 0})',
                            style: robotoRegular.copyWith(fontSize: 10, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Discount / Free delivery tag
                  Positioned(
                    top: 10,
                    right: 50,
                    child: DiscountTagWidget(
                      discount: Get.find<RestaurantController>().getDiscount(restaurant!),
                      discountType: Get.find<RestaurantController>().getDiscountType(restaurant!),
                      freeDelivery: restaurant!.freeDelivery,
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GetBuilder<FavouriteController>(builder: (favController) {
                      bool isFav = favController.wishRestIdList.contains(restaurant!.id);
                      return GlassIconButton(
                        icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        iconColor: isFav ? Colors.redAccent : Colors.white,
                        size: 32,
                        iconSize: 18,
                        onTap: () {
                          if (AuthHelper.isLoggedIn()) {
                            isFav
                                ? favController.removeFromFavouriteList(restaurant!.id, true)
                                : favController.addToFavouriteList(null, restaurant!.id, true);
                          } else {
                            showCustomSnackBar('you_are_not_logged_in'.tr);
                          }
                        },
                      );
                    }),
                  ),
                  // Not available overlay
                  if (!Get.find<RestaurantController>().isOpenNow(restaurant!))
                    const Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        child: NotAvailableWidget(isRestaurant: true),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Restaurant Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant!.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            restaurant!.address ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delivery Time Pill
                    GlassPill(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined, size: 13, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '${restaurant!.deliveryTime ?? '25-35'} min',
                            style: robotoMedium.copyWith(
                              fontSize: 10,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
