import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/cuisine_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/category_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/item_campaign_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/popular_item_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/popular_store_widget1.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class BiteboxxModernHomeScreen extends StatefulWidget {
  final ScrollController scrollController;
  const BiteboxxModernHomeScreen({super.key, required this.scrollController});

  @override
  State<BiteboxxModernHomeScreen> createState() => _BiteboxxModernHomeScreenState();
}

class _BiteboxxModernHomeScreenState extends State<BiteboxxModernHomeScreen> {
  int _selectedServiceIndex = 0; // 0: Food, 1: Groceries

  String _getTimeGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  @override
  Widget build(BuildContext context) {
    final configModel = Get.find<SplashController>().configModel!;
    final bool isDark = Get.isDarkMode;
    final Color bgCanvas = isDark ? const Color(0xFF121214) : const Color(0xFFF7F8FA);

    return Container(
      color: bgCanvas,
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── App Header with Peach Gradient Background ──────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF231A14), Color(0xFF181514), Color(0xFF121214)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFE8D6),
                          Color(0xFFFFF4EC),
                          Color(0xFFF7F8FA),
                        ],
                        stops: [0.0, 0.50, 1.0],
                      ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Avatar + Greeting & Name + Action Buttons
                      GetBuilder<ProfileController>(builder: (profileController) {
                        final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
                        final String userName = isLoggedIn && profileController.userInfoModel != null
                            ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}'.trim()
                            : 'Guest user';
                        final String initials = userName.isNotEmpty
                            ? (userName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase())
                            : 'GU';

                        return Row(
                          children: [
                            // Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: isLoggedIn && profileController.userInfoModel?.imageFullUrl != null
                                    ? CustomImageWidget(
                                        image: profileController.userInfoModel!.imageFullUrl!,
                                        height: 44,
                                        width: 44,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          initials,
                                          style: robotoBold.copyWith(
                                            color: const Color(0xFFFF6000),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Greeting + Name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getTimeGreeting(),
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userName,
                                    style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Quick Action: Location
                            InkWell(
                              onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.location_on_outlined, size: 20, color: Color(0xFF374151)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Quick Action: Settings / Menu
                            InkWell(
                              onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.tune_rounded, size: 20, color: Color(0xFF374151)),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 18),

                      // "Hey, BiteBoxx" headline
                      RichText(
                        text: TextSpan(
                          style: robotoBold.copyWith(
                            fontSize: 26,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                            letterSpacing: -0.5,
                          ),
                          children: const [
                            TextSpan(text: 'Hey, '),
                            TextSpan(
                              text: 'BiteBoxx',
                              style: TextStyle(
                                color: Color(0xFFFF6000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location pill row
                      GetBuilder<LocationController>(builder: (locationController) {
                        final address = AddressHelper.getAddressFromSharedPref()?.address;
                        final String displayAddress = (address != null && address.isNotEmpty)
                            ? address
                            : 'Currently unavailable in this area';

                        return InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFFFF6000), size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  displayAddress,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF6B7280)),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Pill Search Bar
                      InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 22),
                              const SizedBox(width: 12),
                              Text(
                                'search'.tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Category Switcher: [ Food ] [ Groceries ]
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E22) : const Color(0xFFF0EBE6).withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            // Food Pill
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedServiceIndex = 0),
                                borderRadius: BorderRadius.circular(24),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedServiceIndex == 0
                                        ? const Color(0xFFFF6000)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: _selectedServiceIndex == 0
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFFF6000).withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu_rounded,
                                        size: 16,
                                        color: _selectedServiceIndex == 0
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'food'.tr,
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: _selectedServiceIndex == 0
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Groceries Pill
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _selectedServiceIndex = 1),
                                borderRadius: BorderRadius.circular(24),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _selectedServiceIndex == 1
                                        ? const Color(0xFFFF6000)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: _selectedServiceIndex == 1
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFFF6000).withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_basket_outlined,
                                        size: 16,
                                        color: _selectedServiceIndex == 1
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Groceries',
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: _selectedServiceIndex == 1
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : const Color(0xFF6B7280)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Hero Banner Carousel Card (Matching Image 4) ────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF26262A),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Right-side salad / dish image
                    Positioned(
                      right: -10,
                      top: 0,
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        child: Opacity(
                          opacity: 0.85,
                          child: Image.asset(
                            Images.placeholder,
                            width: 170,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(),
                          ),
                        ),
                      ),
                    ),

                    // Left-side Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFFF7A1A)),
                              const SizedBox(width: 4),
                              Text(
                                'Fresh flavours, happy days',
                                style: robotoMedium.copyWith(
                                  color: const Color(0xFFFF903F),
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Heading
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              'A fresh take on mealtime',
                              style: robotoBold.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Subtitle
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Text(
                              'Discover something delicious today.',
                              style: robotoRegular.copyWith(
                                color: Colors.white70,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Button
                          InkWell(
                            onTap: () {
                              widget.scrollController.animateTo(
                                350,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Discover now',
                                style: robotoBold.copyWith(
                                  color: const Color(0xFF1F2937),
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Carousel Dot Indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6000),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.pause, size: 14, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),

          // ── Delivery Location Card (Matching Image 4) ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: ThemeTokens.modernCardBox(radius: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add your delivery location',
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'We need a serviceable address before showing products.',
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
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
                        child: Text(
                          'Add location',
                          style: robotoBold.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Dynamic Store & Food Sections ──────────────────────────────────
          const SliverToBoxAdapter(child: BadWeatherWidget()),

          // Highlight / Promo Cards
          const SliverToBoxAdapter(child: HighlightWidgetView()),

          // Categories Horizontal
          const SliverToBoxAdapter(child: CategoryWidget1()),

          // Popular Restaurants
          (configModel.popularRestaurant == 1)
              ? const SliverToBoxAdapter(child: PopularStoreWidget1(isPopular: true))
              : const SliverToBoxAdapter(child: SizedBox()),

          // Item Campaigns
          const SliverToBoxAdapter(child: ItemCampaignWidget1()),

          // Popular Foods
          (configModel.popularFood == 1)
              ? const SliverToBoxAdapter(child: PopularItemWidget1(isPopular: true))
              : const SliverToBoxAdapter(child: SizedBox()),

          // Cuisines
          const SliverToBoxAdapter(child: CuisineViewWidget()),

          // All Restaurants Section
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                width: Dimensions.webMaxWidth,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'all_restaurants'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: GetBuilder<RestaurantController>(builder: (restaurantController) {
                  return PaginatedListViewWidget(
                    scrollController: widget.scrollController,
                    totalSize: restaurantController.restaurantModel?.totalSize,
                    offset: restaurantController.restaurantModel?.offset,
                    onPaginate: (int? offset) async => await restaurantController.getRestaurantList(offset!, false),
                    productView: ProductViewWidget(
                      isRestaurant: true,
                      products: null,
                      restaurants: restaurantController.restaurantModel?.restaurants,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
