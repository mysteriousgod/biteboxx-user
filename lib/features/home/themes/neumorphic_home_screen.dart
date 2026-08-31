import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
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

class NeumorphicHomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const NeumorphicHomeScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final configModel = Get.find<SplashController>().configModel!;
    final isLogin = Get.find<AuthController>().isLoggedIn();
    final bool isDark = Get.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF1E222B) : const Color(0xFFE9ECF2);

    return Container(
      color: bgColor,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Neumorphic App Bar
          SliverAppBar(
            floating: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: bgColor,
            surfaceTintColor: Colors.transparent,
            title: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6),
                                offset: const Offset(3, 3),
                                blurRadius: 6,
                              ),
                              BoxShadow(
                                color: isDark ? const Color(0xFF2A303C) : Colors.white,
                                offset: const Offset(-3, -3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: GetBuilder<LocationController>(builder: (locationController) {
                            return _buildLocationBar(context);
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Notification Button
                    InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFFA3B1C6),
                              offset: const Offset(3, 3),
                              blurRadius: 6,
                            ),
                            BoxShadow(
                              color: isDark ? const Color(0xFF2A303C) : Colors.white,
                              offset: const Offset(-3, -3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: GetBuilder<NotificationController>(builder: (notificationController) {
                          return Stack(
                            children: [
                              Icon(Icons.notifications_outlined, size: 22, color: Theme.of(context).primaryColor),
                              if (notificationController.hasNotification)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    height: 8,
                                    width: 8,
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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

          // Embossed Search Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverDelegate(
              height: 68,
              child: Center(
                child: Container(
                  color: bgColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.6) : const Color(0xFFB0BDD0),
                            offset: const Offset(4, 4),
                            blurRadius: 6,
                          ),
                          BoxShadow(
                            color: isDark ? const Color(0xFF2B3240) : Colors.white,
                            offset: const Offset(-4, -4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: Theme.of(context).primaryColor, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'search_food_or_restaurant'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.tune_rounded, size: 16, color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Body
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
                      title: 'all_restaurants'.tr,
                      subtitle: 'Explore freshly prepared meals near you',
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
    IconData icon = Icons.location_on_rounded;
    if (currentAddress != null && AuthHelper.isLoggedIn()) {
      if (currentAddress.addressType == 'home') {
        icon = Icons.home_rounded;
      } else if (currentAddress.addressType == 'office') {
        icon = Icons.work_rounded;
      }
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            currentAddress?.address ?? 'Select Location',
            style: robotoMedium.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color,
              fontSize: Dimensions.fontSizeSmall,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).textTheme.bodyLarge!.color, size: 18),
      ],
    );
  }
}
