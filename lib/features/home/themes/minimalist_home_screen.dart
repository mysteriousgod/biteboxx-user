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
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class MinimalistHomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const MinimalistHomeScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final configModel = Get.find<SplashController>().configModel!;
    final isLogin = Get.find<AuthController>().isLoggedIn();
    final bool isDark = Get.isDarkMode;
    final Color bgCanvas = isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);

    return Container(
      color: bgCanvas,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Minimalist Flat App Bar
          SliverAppBar(
            floating: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: bgCanvas,
            title: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                        child: GetBuilder<LocationController>(builder: (locationController) {
                          return _buildLocationBar(context);
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                      child: GetBuilder<NotificationController>(builder: (notificationController) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
                          ),
                          child: Icon(Icons.notifications_none_rounded, size: 20, color: Theme.of(context).textTheme.bodyLarge?.color),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Clean Minimalist Search Input
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverDelegate(
              height: 64,
              child: Center(
                child: Container(
                  color: bgCanvas,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 20, color: Theme.of(context).disabledColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'search_food_or_restaurant'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).disabledColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
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

          // Body
          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
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
                      title: 'all_restaurants'.tr,
                      subtitle: 'Find top-rated restaurants around you',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'DELIVERING TO',
              style: robotoBold.copyWith(fontSize: 10, letterSpacing: 0.8, color: Theme.of(context).disabledColor),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Theme.of(context).disabledColor),
          ],
        ),
        Text(
          currentAddress?.address ?? 'Select Location',
          style: robotoMedium.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: Dimensions.fontSizeSmall,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
