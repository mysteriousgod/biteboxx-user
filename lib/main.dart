import 'dart:async';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/notification/domain/models/notification_body_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/theme_controller.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/deep_link_body.dart';
import 'package:stackfood_multivendor/helper/notification_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/theme/dark_theme.dart';
import 'package:stackfood_multivendor/theme/light_theme.dart';
import 'package:stackfood_multivendor/theme/glass_theme.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/messages.dart';
import 'package:stackfood_multivendor/common/widgets/cookies_view_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';
import 'helper/get_di.dart' as di;

import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  try {
    if(ResponsiveHelper.isMobilePhone()) {
      HttpOverrides.global = MyHttpOverrides();
    }
    setPathUrlStrategy();
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Failed to load .env file: $e");
    }

    // // Pass all uncaught "fatal" errors from the framework to Crashlytics
    // FlutterError.onError = (errorDetails) {
    //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    // };
    // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    //   return true;
    // };

    DeepLinkBody? linkBody;

    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint("Firebase Initialize Failed: $e");
       // Continue, as it might behave differently on web
    }

    Map<String, Map<String, String>> languages = await di.init();

    NotificationBodyModel? body;
    try {
      if (GetPlatform.isMobile) {
        final RemoteMessage? remoteMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (remoteMessage != null) {
          body = NotificationHelper.convertNotification(remoteMessage.data);
        }
        await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
        FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
      }
    }catch(_) {}

    if (ResponsiveHelper.isWeb()) {
      try {
        await FacebookAuth.instance.webAndDesktopInitialize(
          appId: dotenv.env['FACEBOOK_APP_ID'] ?? "452131619626499",
          cookie: true,
          xfbml: true,
          version: "v13.0",
        );
      } catch (e) {
         debugPrint("Facebook Auth Failed: $e");
      }
    }
    runApp(MyApp(languages: languages, body: body, linkBody: linkBody));
  } catch (e, stack) {
    runApp(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Text("Startup Error", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 20),
                Text(e.toString(), style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Text(stack.toString(), style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>>? languages;
  final NotificationBodyModel? body;
  final DeepLinkBody? linkBody;
  const MyApp({super.key, required this.languages, required this.body, required this.linkBody});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();

    _route();
  }

  Future<void> _route() async {
    if(GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      if(!Get.find<AuthController>().isLoggedIn() && !Get.find<AuthController>().isGuestLoggedIn() /*&& !ResponsiveHelper.isDesktop(Get.context!)*/) {
        await Get.find<AuthController>().guestLogin();
      }
      if(Get.find<AuthController>().isLoggedIn() || Get.find<AuthController>().isGuestLoggedIn()) {
        Get.find<CartController>().getCartDataOnline();
      }
      Get.find<SplashController>().getConfigData(fromMainFunction: true);
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<AuthController>().updateToken();
        await Get.find<FavouriteController>().getFavouriteList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ThemeController>(builder: (themeController) {
      return GetBuilder<LocalizationController>(builder: (localizeController) {
        return GetBuilder<SplashController>(builder: (splashController) {
          return (GetPlatform.isWeb && splashController.configModel == null) ? const SizedBox() : GetMaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: Get.key,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            theme: (splashController.activeTheme == 4 || splashController.activeTheme == 9)
                ? (themeController.darkTheme ? glassDarkTheme : glassLightTheme)
                : (themeController.darkTheme ? dark : light),
            locale: localizeController.locale,
            translations: Messages(languages: widget.languages),
            fallbackLocale: Locale(AppConstants.languages[0].languageCode!, AppConstants.languages[0].countryCode),
            initialRoute: GetPlatform.isWeb ? RouteHelper.getInitialRoute() : RouteHelper.getSplashRoute(widget.body, widget.linkBody),
            getPages: RouteHelper.routes,
            defaultTransition: Transition.topLevel,
            transitionDuration: const Duration(milliseconds: 500),
            builder: (BuildContext context, widget) {
              return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)), child: Material(
                child: SafeArea(
                  top: false, bottom: GetPlatform.isAndroid,
                  child: Stack(children: [
                    widget!,

                    GetBuilder<SplashController>(builder: (splashController){

                      if(!splashController.savedCookiesData || !splashController.getAcceptCookiesStatus(splashController.configModel?.cookiesText ?? "")){
                        return ResponsiveHelper.isWeb() ? const Align(alignment: Alignment.bottomCenter, child: CookiesViewWidget()) : const SizedBox();
                      }else{
                        return const SizedBox();
                      }
                    })
                  ]),
                )),
              );
            }
          );
        });
      });
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
