import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/banner_view_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/category_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/cuisine_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/item_campaign_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/popular_item_widget1.dart';
import 'package:stackfood_multivendor/features/home/widgets/theme1/popular_store_widget1.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class CyberpunkHomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const CyberpunkHomeScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final configModel = Get.find<SplashController>().configModel!;
    final isLogin = Get.find<AuthController>().isLoggedIn();
    const Color darkCanvas = ThemeTokens.cyberDark;

    return Container(
      color: darkCanvas,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Cyberpunk App Bar
          SliverAppBar(
            floating: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: darkCanvas,
            title: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: ThemeTokens.cyberBox(accent: ThemeTokens.cyberCyan, radius: 10),
                          child: GetBuilder<LocationController>(builder: (locationController) {
                            return _buildLocationBar(context);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: ThemeTokens.cyberBox(accent: ThemeTokens.cyberPink, radius: 10),
                        child: GetBuilder<NotificationController>(builder: (notificationController) {
                          return Stack(
                            children: [
                              const Icon(Icons.bolt_rounded, size: 22, color: ThemeTokens.cyberPink),
                              if (notificationController.hasNotification)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    height: 8,
                                    width: 8,
                                    decoration: const BoxDecoration(
                                      color: ThemeTokens.cyberYellow,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Cyberpunk Glowing Neon Search Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverDelegate(
              height: 68,
              child: Center(
                child: Container(
                  color: darkCanvas,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: ThemeTokens.cyberCardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ThemeTokens.cyberCyan, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeTokens.cyberCyan.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.terminal_rounded, color: ThemeTokens.cyberCyan, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '// SEARCH_SUPPLY_GRID...',
                              style: robotoMedium.copyWith(
                                color: ThemeTokens.cyberCyan.withValues(alpha: 0.8),
                                fontSize: Dimensions.fontSizeSmall,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: ThemeTokens.cyberPink.withValues(alpha: 0.2),
                              border: Border.all(color: ThemeTokens.cyberPink, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'LIVE',
                              style: robotoBold.copyWith(fontSize: 10, color: ThemeTokens.cyberPink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const BannerViewWidget1(),
                    const BadWeatherWidget(),
                    const HighlightWidgetView(),
                    const CategoryWidget1(),
                    const ItemCampaignWidget1(),
                    if (isLogin) const PopularStoreWidget1(isOrderAgainViewed: true, isPopular: false),
                    const CuisinesWidget1(),
                    if (configModel.popularRestaurant == 1) const PopularStoreWidget1(isPopular: true),
                    if (configModel.popularFood == 1) const PopularItemWidget1(isPopular: true),
                    if (configModel.newRestaurant == 1) const PopularStoreWidget1(isPopular: false),
                    const SizedBox(height: 16),
                    ThemedSectionHeader(
                      title: 'CONNECTED VENDORS',
                      titleColor: ThemeTokens.cyberCyan,
                      subtitle: 'Active cyber food outposts in your sector',
                    ),
                    GetBuilder<RestaurantController>(builder: (restaurantController) {
                      return PaginatedListViewWidget(
                        scrollController: scrollController,
                        totalSize: restaurantController.restaurantModel?.totalSize,
                        offset: restaurantController.restaurantModel?.offset,
                        onPaginate: (int? offset) async => await restaurantController.getRestaurantList(offset!, false),
                        productView: ProductViewWidget(
                          isRestaurant: true,
                          products: null,
                          showTheme1Restaurant: true,
                          restaurants: restaurantController.restaurantModel?.restaurants,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.paddingSizeExtraSmall
                                : Dimensions.paddingSizeSmall,
                            vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context) {
    final currentAddress = AddressHelper.getAddressFromSharedPref();
    return Row(
      children: [
        const Icon(Icons.radar_rounded, size: 18, color: ThemeTokens.cyberCyan),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            currentAddress?.address ?? 'SECTOR UNASSIGNED',
            style: robotoMedium.copyWith(
              color: Colors.white,
              fontSize: Dimensions.fontSizeSmall,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Icon(Icons.arrow_drop_down, color: ThemeTokens.cyberCyan, size: 20),
      ],
    );
  }
}
