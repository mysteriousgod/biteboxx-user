import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/product_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/home/themes/glass_components.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/dine_in_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/filter_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/home/widgets/order_again_view_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/refer_banner_view_widget.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class GlassmorphicHomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const GlassmorphicHomeScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final configModel = Get.find<SplashController>().configModel;
    final isLogin = Get.find<AuthController>().isLoggedIn();
    final bool showPopularRestaurant = (configModel?.popularRestaurant ?? 1) == 1;
    final bool showPopularFood = (configModel?.popularFood ?? 1) == 1;
    final bool showNewRestaurant = (configModel?.newRestaurant ?? 1) == 1;
    final bool showMostReviewed = (configModel?.mostReviewedFoods ?? 1) == 1;

    return GlassAuroraBackground(
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar (Aligned with Theme 1 polish)
          SliverAppBar(
            floating: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                height: 50,
                child: Row(
                  children: [
                    Image.asset(Images.logo, height: 30, width: 30),
                    const SizedBox(width: 8),
                    Text(
                      'BiteBoxx',
                      style: robotoBold.copyWith(
                        fontSize: 18,
                        color: Get.isDarkMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeSmall,
                            horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0,
                          ),
                          child: GetBuilder<LocationController>(builder: (locationController) {
                            return _buildLocationBar(context);
                          }),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                      child: GetBuilder<NotificationController>(builder: (notificationController) {
                        return Stack(
                          children: [
                            GlassContainer(
                              radius: 30,
                              blur: 14,
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (notificationController.hasNotification)
                              Positioned(
                                top: 2,
                                right: 2,
                                child: Container(
                                  height: 8,
                                  width: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            actions: const [SizedBox()],
          ),

          // Pinned Frosted Glass Search Bar (Clean 50px pill as in Theme 1)
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverDelegate(
              child: Center(
                child: Container(
                  height: 50,
                  width: Dimensions.webMaxWidth,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                    child: GlassContainer(
                      radius: 25,
                      blur: 18,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: Row(
                        children: [
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Text(
                              'are_you_hungry'.tr,
                              style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.tune_rounded,
                            size: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Home Content
          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlassBannerView(),
                    const BadWeatherWidget(),
                    const GlassCategorySection(),
                    const GlassItemCampaignSection(),
                    const HighlightWidgetView(),

                    if (isLogin) ...[
                      const GlassPopularStoreSection(isPopular: false, isOrderAgainViewed: true),
                      const OrderAgainViewWidget(),
                    ],

                    if (showMostReviewed)
                      const GlassPopularFoodSection(isPopular: false),

                    if (configModel?.dineInOrderOption ?? false)
                      DineInWidget(),

                    const ReferBannerViewWidget(fromTheme1: true),

                    if (isLogin)
                      const GlassPopularStoreSection(isPopular: false, isRecentlyViewed: true),

                    const GlassCuisineSection(),

                    if (showPopularRestaurant)
                      const GlassPopularStoreSection(isPopular: true),

                    if (showPopularFood)
                      const GlassPopularFoodSection(isPopular: true),

                    if (showNewRestaurant)
                      const GlassPopularStoreSection(isPopular: false),

                    // Filter Bar for All Restaurants (Identical to Theme 1)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'all_restaurants'.tr,
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          const FilterViewWidget(),
                        ],
                      ),
                    ),

                    // All Restaurants Grid (Same production-grade widget as Theme 1)
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
                            horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                            vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : 0,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 35),
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
    IconData icon = Icons.near_me_rounded;
    if (currentAddress != null && AuthHelper.isLoggedIn()) {
      if (currentAddress.addressType == 'home') {
        icon = Icons.home_rounded;
      } else if (currentAddress.addressType == 'office') {
        icon = Icons.apartment_rounded;
      }
    }

    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            currentAddress?.address ?? 'Select Location',
            style: robotoMedium.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeSmall,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          size: 18,
        ),
      ],
    );
  }
}
