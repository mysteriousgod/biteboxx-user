
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/countdown/controllers/countdown_controller.dart';
import 'package:stackfood_multivendor/features/countdown/views/countdown_view.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/helper/maintance_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';

void route({required NotificationBodyModel? notificationBody, required DeepLinkBody? linkBody}) {
  double? minimumVersion = _getMinimumVersion();
  bool needsUpdate = AppConstants.appVersion < minimumVersion;

  bool isInMaintenance = MaintenanceHelper.isMaintenanceEnable();
  if (needsUpdate || isInMaintenance) {
    Get.offNamed(RouteHelper.getUpdateRoute(needsUpdate));
  } else if (Get.currentRoute.contains(RouteHelper.update) && !isInMaintenance) {
    Get.offNamed(RouteHelper.getInitialRoute());
  } else if (!isInMaintenance) {
    // Check countdown launch status (for all platforms: web, iOS, Android)
    final countdownController = Get.find<CountdownController>();
    
    // Show countdown if not yet launched
    if (!countdownController.countdownModel.isLaunched) {
      Get.off(() => const CountdownView());
    } else {
      // App has launched, proceed with normal navigation
      _handleNavigation(notificationBody, linkBody);
    }
  }
}

double _getMinimumVersion() {
  if (GetPlatform.isAndroid) {
    return Get.find<SplashController>().configModel!.appMinimumVersionAndroid!;
  } else if (GetPlatform.isIOS) {
    return Get.find<SplashController>().configModel!.appMinimumVersionIos!;
  } else {
    return 0;
  }
}

void _handleNavigation(NotificationBodyModel? notificationBody, DeepLinkBody? linkBody) async {
  if (notificationBody != null && linkBody == null) {
    _forNotificationRouteProcess(notificationBody);
  } else if (Get.find<AuthController>().isLoggedIn()) {
    _forLoggedInUserRouteProcess();
  } else if (Get.find<SplashController>().showIntro()!) {
    _newlyRegisteredRouteProcess();
  } else if (Get.find<AuthController>().isGuestLoggedIn()) {
    _forGuestUserRouteProcess();
  } else {
    await Get.find<AuthController>().guestLogin();
    _forGuestUserRouteProcess();
  }
}

void _forNotificationRouteProcess(NotificationBodyModel? notificationBody) {
  if(notificationBody!.notificationType == NotificationType.order) {
    Get.toNamed(RouteHelper.getOrderDetailsRoute(notificationBody.orderId, fromNotification: true));
  }else if(notificationBody.notificationType == NotificationType.message) {
    Get.toNamed(RouteHelper.getChatRoute(notificationBody: notificationBody, conversationID: notificationBody.conversationId, fromNotification: true));
  }else if(notificationBody.notificationType == NotificationType.block || notificationBody.notificationType == NotificationType.unblock){
    Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.notification));
  }else if(notificationBody.notificationType == NotificationType.add_fund || notificationBody.notificationType == NotificationType.referral_earn || notificationBody.notificationType == NotificationType.CashBack){
    Get.toNamed(RouteHelper.getWalletRoute(fromNotification: true));
  }else{
    Get.toNamed(RouteHelper.getNotificationRoute(fromNotification: true));
  }
}

Future<void> _forLoggedInUserRouteProcess() async {
  Get.find<AuthController>().updateToken();
  await Get.find<FavouriteController>().getFavouriteList();
  await Get.find<SplashController>().autoCheckLocationAndNavigate('splash', offNamed: true);
}

void _newlyRegisteredRouteProcess() {
  if(AppConstants.languages.length > 1) {
    Get.offNamed(RouteHelper.getLanguageRoute('splash'));
  }else {
    Get.offNamed(RouteHelper.getOnBoardingRoute());
  }
}

Future<void> _forGuestUserRouteProcess() async {
  await Get.find<SplashController>().autoCheckLocationAndNavigate('splash', offNamed: true);
}