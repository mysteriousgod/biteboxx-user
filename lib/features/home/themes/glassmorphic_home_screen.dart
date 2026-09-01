import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/paginated_list_view_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/home/screens/home_screen.dart';
import 'package:stackfood_multivendor/features/home/themes/glass_components.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/features/home/widgets/bad_weather_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/highlight_widget_view.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/notification/controllers/notification_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/controllers/restaurant_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class GlassmorphicHomeScreen extends StatelessWidget {
  final ScrollController scrollController;
  const GlassmorphicHomeScreen({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final configModel = Get.find<SplashController>().configModel!;
    final isLogin = Get.find<AuthController>().isLoggedIn();

    return GlassAuroraBackground(
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            floating: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  radius: 20,
                  blur: 16,
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
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                        child: GetBuilder<NotificationController>(builder: (notificationController) {
                          return Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(Icons.notifications_none_rounded, size: 20, color: Theme.of(context).primaryColor),
                              ),
                              if (notificationController.hasNotification)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    height: 8,
                                    width: 8,
                                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
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
            ),
          ),

          // Frosted Glass Search Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverDelegate(
              height: 68,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GlassContainer(
                    radius: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    blur: 18,
                    child: InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, color: Theme.of(context).primaryColor, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'search_food_or_restaurant'.tr,
                              style: robotoRegular.copyWith(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                                fontSize: Dimensions.fontSizeSmall,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.tune_rounded, color: Theme.of(context).primaryColor, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Glass Feed Content
          SliverToBoxAdapter(
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    const GlassBannerView(),
                    const BadWeatherWidget(),
                    const HighlightWidgetView(),
                    const GlassCategorySection(),
                    const GlassItemCampaignSection(),
                    if (isLogin)
                      const GlassPopularStoreSection(isOrderAgainViewed: true, isPopular: false),
                    const GlassCuisineSection(),
                    if (configModel.popularRestaurant == 1)
                      const GlassPopularStoreSection(isPopular: true),
                    if (configModel.popularFood == 1)
                      const GlassPopularFoodSection(isPopular: true),
                    if (configModel.newRestaurant == 1)
                      const GlassPopularStoreSection(isPopular: false),
                    if (configModel.mostReviewedFoods == 1)
                      const GlassPopularFoodSection(isPopular: false),
                    const SizedBox(height: 16),

                    ThemedSectionHeader(
                      title: 'all_restaurants'.tr,
                      subtitle: 'Freshly prepared dishes delivered right to you',
                    ),
                    GetBuilder<RestaurantController>(builder: (restaurantController) {
                      final restaurants = restaurantController.restaurantModel?.restaurants;
                      return PaginatedListViewWidget(
                        scrollController: scrollController,
                        totalSize: restaurantController.restaurantModel?.totalSize,
                        offset: restaurantController.restaurantModel?.offset,
                        onPaginate: (int? offset) async => await restaurantController.getRestaurantList(offset!, false),
                        productView: restaurants != null
                            ? ListView.builder(
                                itemCount: restaurants.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  return GlassRestaurantCard(
                                    restaurant: restaurants[index],
                                  );
                                },
                              )
                            : const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                                  child: CircularProgressIndicator(),
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
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
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
        Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).textTheme.bodyLarge?.color, size: 18),
      ],
    );
  }
}

