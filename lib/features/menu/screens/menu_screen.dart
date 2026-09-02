import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/home/themes/glass_components.dart';
import 'package:stackfood_multivendor/features/home/themes/theme_tokens.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:stackfood_multivendor/features/menu/widgets/portion_widget.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/auth/screens/sign_in_screen.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/confirmation_dialog_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      final bool isGlassmorphic = splashController.activeTheme == 4 || splashController.activeTheme == 9;

      Widget screenContent = Scaffold(
        backgroundColor: isGlassmorphic ? Colors.transparent : Theme.of(context).cardColor,
        body: GetBuilder<ProfileController>(
          builder: (profileController) {
            final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

            return Column(children: [

              // Top User Profile Header
              isGlassmorphic
                  ? SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: GlassContainer(
                              radius: 24,
                              blur: 18,
                              padding: const EdgeInsets.all(16),
                              child: Row(children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: ClipOval(child: CustomImageWidget(
                                    placeholder: isLoggedIn ? Images.profilePlaceholder : Images.guestIcon,
                                    image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                                    height: 62, width: 62, fit: BoxFit.cover,
                                  )),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeDefault),

                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    isLoggedIn && profileController.userInfoModel == null ? Shimmer(
                                      duration: const Duration(seconds: 2),
                                      enabled: true,
                                      child: Container(
                                        height: 16, width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        ),
                                      ),
                                    ) : Text(
                                      isLoggedIn ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName}' : 'guest_user'.tr,
                                      style: robotoBold.copyWith(
                                        fontSize: Dimensions.fontSizeLarge,
                                        color: Get.isDarkMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                    isLoggedIn && profileController.userInfoModel != null ? Text(
                                      '${'joined'.tr} ${DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!)}',
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ) : InkWell(
                                      onTap: () async {
                                        if(!ResponsiveHelper.isDesktop(context)) {
                                          Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute))?.then((value) {
                                            if(AuthHelper.isLoggedIn()) {
                                              profileController.getUserInfo();
                                            }
                                          });
                                        }else{
                                          Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: true)).then((value) {
                                            if(AuthHelper.isLoggedIn()) {
                                              profileController.getUserInfo();
                                            }
                                          });
                                        }
                                      },
                                      child: Text(
                                        'login_to_view_all_feature'.tr,
                                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white.withValues(alpha: 0.85)),
                                      ),
                                    ),
                                  ]),
                                ),

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GlassPill(
                                      tintColor: Theme.of(context).primaryColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                          const SizedBox(width: 3),
                                          Text(
                                            isLoggedIn ? 'VIP' : 'GUEST',
                                            style: robotoBold.copyWith(fontSize: 10, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isLoggedIn) ...[
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.edit_outlined, size: 16, color: Theme.of(context).primaryColor),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ]),
                            ),
                          ),

                          // 3 Frosted Stat Cards (from Theme 1 Profile Screen)
                          if (isLoggedIn)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                              child: Row(children: [
                                Expanded(
                                  child: GlassContainer(
                                    radius: 18,
                                    blur: 16,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                    child: Column(children: [
                                      Icon(Icons.stars_rounded, size: 22, color: Theme.of(context).primaryColor),
                                      const SizedBox(height: 4),
                                      Text(
                                        profileController.userInfoModel?.loyaltyPoint != null
                                            ? profileController.userInfoModel!.loyaltyPoint.toString()
                                            : '0',
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Get.isDarkMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'loyalty_points'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: 10,
                                          color: Get.isDarkMode ? Colors.white70 : Theme.of(context).disabledColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GlassContainer(
                                    radius: 18,
                                    blur: 16,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                    child: Column(children: [
                                      Icon(Icons.shopping_bag_outlined, size: 22, color: Theme.of(context).primaryColor),
                                      const SizedBox(height: 4),
                                      Text(
                                        profileController.userInfoModel?.orderCount != null
                                            ? profileController.userInfoModel!.orderCount.toString()
                                            : '0',
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeLarge,
                                          color: Get.isDarkMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'total_order'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: 10,
                                          color: Get.isDarkMode ? Colors.white70 : Theme.of(context).disabledColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GlassContainer(
                                    radius: 18,
                                    blur: 16,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                    child: Column(children: [
                                      Icon(Icons.account_balance_wallet_outlined, size: 22, color: Theme.of(context).primaryColor),
                                      const SizedBox(height: 4),
                                      Text(
                                        PriceConverter.convertPrice(
                                          profileController.userInfoModel?.walletBalance != null
                                              ? profileController.userInfoModel!.walletBalance
                                              : 0,
                                        ),
                                        style: robotoBold.copyWith(
                                          fontSize: Dimensions.fontSizeSmall,
                                          color: Get.isDarkMode ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'wallet_balance'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: 10,
                                          color: Get.isDarkMode ? Colors.white70 : Theme.of(context).disabledColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ]),
                                  ),
                                ),
                              ]),
                            ),
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeOverLarge, right: Dimensions.paddingSizeOverLarge,
                          top: 50, bottom: Dimensions.paddingSizeOverLarge,
                        ),
                        child: Row(children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(1),
                            child: ClipOval(child: CustomImageWidget(
                              placeholder: isLoggedIn ? Images.profilePlaceholder : Images.guestIcon,
                              image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                              height: 70, width: 70, fit: BoxFit.cover, imageColor: isLoggedIn ? Theme.of(context).hintColor : null,
                            )),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeDefault),

                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              isLoggedIn && profileController.userInfoModel == null ? Shimmer(
                                duration: const Duration(seconds: 2),
                                enabled: true,
                                child: Container(
                                  height: 16, width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 200],
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                ),
                              ) : Text(
                                isLoggedIn ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName}' : 'guest_user'.tr,
                                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              isLoggedIn && profileController.userInfoModel != null ? Text(
                                DateConverter.containTAndZToUTCFormat(profileController.userInfoModel!.createdAt!),
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                              ) : InkWell(
                                onTap: () async {
                                  if(!ResponsiveHelper.isDesktop(context)) {
                                    Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute))?.then((value) {
                                      if(AuthHelper.isLoggedIn()) {
                                        profileController.getUserInfo();
                                      }
                                    });
                                  }else{
                                    Get.dialog(const SignInScreen(exitFromApp: true, backFromThis: true)).then((value) {
                                      if(AuthHelper.isLoggedIn()) {
                                        profileController.getUserInfo();
                                      }
                                    });
                                  }
                                },
                                child: Text(
                                  'login_to_view_all_feature'.tr,
                                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    ),

              // Menu Sections List
              Expanded(child: SingleChildScrollView(
                child: Ink(
                  color: isGlassmorphic
                      ? Colors.transparent
                      : Get.find<ThemeController>().darkTheme ? Theme.of(context).colorScheme.surface : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  padding: EdgeInsets.only(top: isGlassmorphic ? 4 : Dimensions.paddingSizeLarge),
                  child: Column(children: [

                    // General Section
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildSectionTitle('general'.tr, isGlassmorphic),

                      _buildSectionCard(
                        isGlassmorphic: isGlassmorphic,
                        child: Column(children: [
                          PortionWidget(icon: Images.profileIcon, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
                          PortionWidget(icon: Images.addressIcon, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
                          PortionWidget(icon: Images.languageIcon, title: 'language'.tr, onTap: ()=> _manageLanguageFunctionality(), route: ''),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            child: Row(children: [
                              Icon(
                                Icons.tonality_outlined,
                                size: 18,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(width: Dimensions.paddingSizeSmall),

                              Expanded(
                                child: Text(
                                  'dark_mode'.tr,
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                ),
                              ),

                              SizedBox(
                                height: 26,
                                child: Transform.scale(
                                  scale: 0.78,
                                  child: CupertinoSwitch(
                                    value: Get.isDarkMode,
                                    activeTrackColor: Theme.of(context).primaryColor,
                                    inactiveTrackColor: Theme.of(context).disabledColor.withValues(alpha: 0.35),
                                    onChanged: (bool value) {
                                      Get.find<ThemeController>().toggleTheme();
                                    },
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                    ]),

                    // Promotional Activity Section
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildSectionTitle('promotional_activity'.tr, isGlassmorphic),

                      _buildSectionCard(
                        isGlassmorphic: isGlassmorphic,
                        child: Column(children: [
                          PortionWidget(icon: Images.couponIcon, title: 'coupon'.tr, route: RouteHelper.getCouponRoute(fromCheckout: false)),

                          (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1) ? PortionWidget(
                            icon: Images.pointIcon, title: 'loyalty_points'.tr, route: RouteHelper.getLoyaltyRoute(),
                            hideDivider: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
                            suffix: !isLoggedIn ? null : '${profileController.userInfoModel?.loyaltyPoint != null ? Get.find<ProfileController>().userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}' ,
                          ) : const SizedBox(),

                          (Get.find<SplashController>().configModel!.customerWalletStatus == 1) ? PortionWidget(
                            icon: Images.walletIcon, title: 'my_wallet'.tr, hideDivider: true, route: RouteHelper.getWalletRoute(fromMenuPage: true),
                            suffix: !isLoggedIn ? null : PriceConverter.convertPrice(profileController.userInfoModel != null ? Get.find<ProfileController>().userInfoModel!.walletBalance : 0),
                          ) : const SizedBox(),
                        ]),
                      ),
                    ]),

                    // Earnings Section
                    (Get.find<SplashController>().configModel!.refEarningStatus == 1)
                     || (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context))
                     || (Get.find<SplashController>().configModel!.toggleRestaurantRegistration! && !ResponsiveHelper.isDesktop(context)) ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildSectionTitle('earnings'.tr, isGlassmorphic),

                      _buildSectionCard(
                        isGlassmorphic: isGlassmorphic,
                        child: Column(children: [
                          (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) ? PortionWidget(
                            icon: Images.referIcon, title: 'refer_and_earn'.tr, route: RouteHelper.getReferAndEarnRoute(),
                          ) : const SizedBox(),

                          (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
                            icon: Images.dmIcon, title: 'join_as_a_delivery_man'.tr, route: RouteHelper.getDeliverymanRegistrationRoute(),
                          ) : const SizedBox(),

                          (Get.find<SplashController>().configModel!.toggleRestaurantRegistration! && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
                            icon: Images.storeIcon, title: 'open_store'.tr, hideDivider: true, route: RouteHelper.getRestaurantRegistrationRoute(),
                          ) : const SizedBox(),
                        ]),
                      ),
                    ]) : const SizedBox(),

                    // Help & Support Section
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _buildSectionTitle('help_and_support'.tr, isGlassmorphic),

                      _buildSectionCard(
                        isGlassmorphic: isGlassmorphic,
                        child: Column(children: [
                          PortionWidget(icon: Images.chatIcon, title: 'complaint_about_our_services'.tr, route: RouteHelper.getConversationRoute()),
                          PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                          PortionWidget(icon: Images.aboutIcon, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                          PortionWidget(icon: Images.termsIcon, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                          PortionWidget(icon: Images.privacyIcon, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),

                          (Get.find<SplashController>().configModel!.refundPolicyStatus == 1 ) ? PortionWidget(
                            icon: Images.refundIcon, title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy'),
                          ) : const SizedBox(),

                          (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ? PortionWidget(
                            icon: Images.cancelationIcon, title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy'),
                          ) : const SizedBox(),

                          (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? PortionWidget(
                            icon: Images.shippingIcon, title: 'shipping_policy'.tr, hideDivider: true, route: RouteHelper.getHtmlRoute('shipping-policy'),
                          ) : const SizedBox(),
                        ]),
                      ),
                    ]),

                    // Logout / Sign In Action
                    InkWell(
                      onTap: () async {
                        if(Get.find<AuthController>().isLoggedIn()) {
                          Get.dialog(ConfirmationDialogWidget(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () async {
                            Get.find<ProfileController>().setForceFullyUserEmpty();
                            Get.find<AuthController>().socialLogout();
                            Get.find<AuthController>().resetOtpView();
                            Get.find<CartController>().clearCartList();
                            Get.find<FavouriteController>().removeFavourites();
                            await Get.find<AuthController>().clearSharedData();
                            Get.offAllNamed(RouteHelper.getInitialRoute());
                          }), useSafeArea: false);
                        }else {
                          Get.find<FavouriteController>().removeFavourites();
                          await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                          if(AuthHelper.isLoggedIn()) {
                            await Get.find<FavouriteController>().getFavouriteList();
                            profileController.getUserInfo();
                          }
                        }
                      },
                      child: isGlassmorphic
                          ? GlassContainer(
                              radius: 30,
                              blur: 14,
                              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent),
                                  child: const Icon(Icons.power_settings_new_sharp, size: 14, color: Colors.white),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),

                                Text(
                                  Get.find<AuthController>().isLoggedIn() ? 'logout'.tr : 'sign_in'.tr,
                                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white),
                                ),
                              ]),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                                  child: Icon(Icons.power_settings_new_sharp, size: 14, color: Theme.of(context).cardColor),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                Text(Get.find<AuthController>().isLoggedIn() ? 'logout'.tr : 'sign_in'.tr, style: robotoMedium)
                              ]),
                            ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeOverLarge)

                  ]),
                ),
              )),
            ]);
          }
        ),
      );

      return isGlassmorphic
          ? GlassAuroraBackground(child: screenContent)
          : screenContent;
    });
  }

  Widget _buildSectionCard({required Widget child, required bool isGlassmorphic}) {
    if (isGlassmorphic) {
      return GlassContainer(
        radius: 20,
        blur: 16,
        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
        child: child,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, bool isGlassmorphic) {
    final bool isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault + 4, bottom: 6, top: 10),
      child: Text(
        title,
        style: robotoBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: isGlassmorphic
              ? (isDark ? Colors.white.withValues(alpha: 0.85) : Theme.of(context).primaryColor)
              : Theme.of(context).primaryColor.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}
