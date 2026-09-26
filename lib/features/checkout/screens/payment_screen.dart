import 'dart:async';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/fund_payment_dialog_widget.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/helper/upi_payment_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final String paymentMethod;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String guestId;
  final String contactNumber;
  final int? restaurantId;
  final int? packageId;
  const PaymentScreen({super.key, required this.orderModel, required this.paymentMethod, this.addFundUrl, this.subscriptionUrl,
    required this.guestId, required this.contactNumber, this.restaurantId, this.packageId});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> with WidgetsBindingObserver {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  double? maxCodOrderAmount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    String customerId = '';
    if (widget.orderModel.userId != null && widget.orderModel.userId != 0) {
      customerId = widget.orderModel.userId.toString();
    } else if (widget.guestId.isNotEmpty) {
      customerId = widget.guestId;
    } else if (Get.isRegistered<ProfileController>() && Get.find<ProfileController>().userInfoModel?.id != null) {
      customerId = Get.find<ProfileController>().userInfoModel!.id.toString();
    } else if (Get.isRegistered<AuthController>()) {
      customerId = Get.find<AuthController>().getGuestId();
    }

    if((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) && (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      selectedUrl = '${AppConstants.baseUrl}/payment-mobile?customer_id=$customerId&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
    } else if(widget.subscriptionUrl != null && widget.subscriptionUrl!.isNotEmpty){
      selectedUrl = widget.subscriptionUrl!;
    } else {
      selectedUrl = widget.addFundUrl!;
    }
    _initData();
  }

  void _initData() async {

    if(widget.addFundUrl == null || widget.addFundUrl!.isEmpty){
      ZoneData zoneData = AddressHelper.getAddressFromSharedPref()!.zoneData!.firstWhere((data) => data.id == widget.orderModel.restaurant!.zoneId);
      maxCodOrderAmount = zoneData.maxCodOrderAmount;
    }

    browser = MyInAppBrowser(orderID: widget.orderModel.id.toString(), orderAmount: widget.orderModel.orderAmount, maxCodOrderAmount: maxCodOrderAmount, addFundUrl: widget.addFundUrl,
        subscriptionUrl: widget.subscriptionUrl, contactNumber: widget.contactNumber, restaurantId: widget.restaurantId, packageId: widget.packageId, isDeliveryOrder: widget.orderModel.orderType == 'delivery', paymentMethod: widget.paymentMethod);

    if(!GetPlatform.isIOS) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);

      bool swAvailable = await WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      bool swInterceptAvailable = await WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController = ServiceWorkerController.instance();
        await serviceWorkerController.setServiceWorkerClient(ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            if (kDebugMode) {
              print(request);
            }
            return null;
          },
        ));
      }
    }

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(
          useShouldOverrideUrlLoading: true,
          useOnLoadResource: true,
          userAgent: GetPlatform.isIOS
              ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1'
              : 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          domStorageEnabled: true,
          supportMultipleWindows: true,
          javaScriptCanOpenWindowsAutomatically: true,
        ),
        browserSettings: InAppBrowserSettings(hideUrlBar: true, hideToolbarTop: GetPlatform.isAndroid),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && browser.isAwaitingUpiReturn && browser.canRedirect) {
      if (kDebugMode) {
        print('Resumed in PaymentScreen, verifying UPI status...');
      }
      _verifyStatusOnResume();
    }
  }

  Future<bool> _verifyPaymentWithBackend(String orderId) async {
    bool isPaid = false;

    // 1. Actively query gateway status API for Paytm (triggers backend getTxnStatus)
    if (widget.paymentMethod.toLowerCase().contains('paytm')) {
      try {
        final res = await Get.find<ApiClient>().getData('/payment/paytm/status?order_id=$orderId');
        if (res.statusCode == 200 && res.body != null) {
          if (res.body['is_paid'] == 1 || res.body['status'] == 'paid') {
            isPaid = true;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Paytm status API check error: $e');
        }
      }
    }

    // 2. Track order in order controller to get latest DB status
    try {
      final orderController = Get.find<OrderController>();
      await orderController.trackOrder(
        orderId,
        null,
        false,
        contactNumber: widget.contactNumber,
      );
      if (orderController.trackModel?.paymentStatus == 'paid') {
        isPaid = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Track order error: $e');
      }
    }

    return isPaid;
  }

  Future<void> _verifyStatusOnResume() async {
    final orderId = widget.orderModel.id;
    if (orderId != null && orderId != 0) {
      for (int i = 0; i < 8; i++) {
        if (!browser.canRedirect || !mounted) break;
        await Future.delayed(const Duration(milliseconds: 2500));
        try {
          bool isPaid = await _verifyPaymentWithBackend(orderId.toString());
          if (isPaid) {
            if (kDebugMode) {
              print('Order confirmed as paid on resume!');
            }
            browser.isAwaitingUpiReturn = false;
            browser.close();
            browser.triggerSuccessRedirect();
            return;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error checking payment status on resume: $e');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          _exitApp();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: CustomAppBarWidget(title: 'payment'.tr, onBackPressed: () => _exitApp()),
        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                _isLoading ? Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                ) : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    if (kDebugMode) {
      print('---------- : ${widget.orderModel.orderStatus} / ${widget.orderModel.paymentMethod}/ ${widget.orderModel.id}');
      print('---check------- : ${widget.addFundUrl == null} && ${widget.addFundUrl!.isEmpty} && ${widget.subscriptionUrl == ''} && ${widget.subscriptionUrl!.isEmpty}');
    }

    if (widget.orderModel.id != null && widget.orderModel.id != 0) {
      bool isPaid = await _verifyPaymentWithBackend(widget.orderModel.id.toString());
      if (isPaid) {
        browser.triggerSuccessRedirect();
        return true;
      }
    }

    if((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) && (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)){
      return Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: maxCodOrderAmount,
        contactPersonNumber: widget.contactNumber,
      ), barrierDismissible: false);
    } else {
      return Get.dialog(FundPaymentDialogWidget(isSubscription: widget.subscriptionUrl != null && widget.subscriptionUrl!.isNotEmpty));
    }
  }

}

class MyInAppBrowser extends InAppBrowser {
  final String orderID;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String? contactNumber;
  final int? restaurantId;
  final int? packageId;
  final bool isDeliveryOrder;
  final String paymentMethod;
  bool isAwaitingUpiReturn = false;

  MyInAppBrowser({required this.orderID, required this.orderAmount, required this.maxCodOrderAmount, this.contactNumber, super.windowId,
    super.initialUserScripts, this.addFundUrl, this.subscriptionUrl, this.restaurantId, this.packageId, this.isDeliveryOrder = false, required this.paymentMethod});

  bool _canRedirect = true;
  bool get canRedirect => _canRedirect;

  Future<bool> _verifyPaymentWithBackend(String orderId) async {
    bool isPaid = false;
    if (paymentMethod.toLowerCase().contains('paytm')) {
      try {
        final res = await Get.find<ApiClient>().getData('/payment/paytm/status?order_id=$orderId');
        if (res.statusCode == 200 && res.body != null) {
          if (res.body['is_paid'] == 1 || res.body['status'] == 'paid') {
            isPaid = true;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Paytm status API check error: $e');
        }
      }
    }
    try {
      final orderController = Get.find<OrderController>();
      await orderController.trackOrder(orderId, null, false, contactNumber: contactNumber);
      if (orderController.trackModel?.paymentStatus == 'paid') {
        isPaid = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Track order error: $e');
      }
    }
    return isPaid;
  }

  void triggerSuccessRedirect() {
    _redirect('${AppConstants.baseUrl}/payment-success', contactNumber, restaurantId, packageId);
  }

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {
    if (kDebugMode) {
      print("\n\nStarted: $url\n\n");
    }
    _redirect(url.toString(), contactNumber, restaurantId, packageId);
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("\n\nStopped: $url\n\n");
    }
    _redirect(url.toString(), contactNumber, restaurantId, packageId);
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    if (kDebugMode) {
      print("Can't load [$url] Error: $message");
    }
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() async {
    if(_canRedirect) {
      if (orderID.isNotEmpty && orderID != '0') {
        bool isPaid = await _verifyPaymentWithBackend(orderID);
        if (isPaid) {
          triggerSuccessRedirect();
          return;
        }
      }

      if((addFundUrl == null || addFundUrl!.isEmpty) && (subscriptionUrl == null || subscriptionUrl!.isEmpty)){
        Get.dialog(PaymentFailedDialog(
          orderID: orderID,
          orderAmount: orderAmount,
          maxCodOrderAmount: maxCodOrderAmount,
          contactPersonNumber: contactNumber,
        ), barrierDismissible: false);
      } else {
        Get.dialog(FundPaymentDialogWidget(isSubscription: subscriptionUrl != null && subscriptionUrl!.isNotEmpty));
      }
    }
    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) async {
    Uri? uri = navigationAction.request.url;
    if (uri != null) {
      String urlString = uri.toString();
      if (kDebugMode) {
        print("\n\nOverride URL: $urlString\n\n");
      }

      if (urlString.startsWith(AppConstants.baseUrl)) {
        _redirect(urlString, contactNumber, restaurantId, packageId);
        return NavigationActionPolicy.ALLOW;
      }

      if (UpiPaymentHelper.isUpiOrIntentUrl(urlString, uri)) {
        isAwaitingUpiReturn = true;
        await UpiPaymentHelper.launchUpiPayment(urlString);
        return NavigationActionPolicy.CANCEL;
      }
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      print("Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

  void _redirect(String url, String? contactNumber, int? restaurantId, int? packageId) async {
    bool forSubscription = (subscriptionUrl != null && subscriptionUrl!.isNotEmpty && (addFundUrl == null || addFundUrl!.isEmpty));

    if(_canRedirect) {
      bool isSuccess = forSubscription ? url.startsWith('${AppConstants.baseUrl}/subscription-success')
          : url.startsWith('${AppConstants.baseUrl}/payment-success');
      bool isFailed = forSubscription ? url.startsWith('${AppConstants.baseUrl}/subscription-fail')
          : url.startsWith('${AppConstants.baseUrl}/payment-fail');
      bool isCancel = forSubscription ? url.startsWith('${AppConstants.baseUrl}/subscription-cancel')
          : url.startsWith('${AppConstants.baseUrl}/payment-cancel');
      if (!isSuccess && !isFailed && !isCancel) return;

      _canRedirect = false;

      if ((isFailed || isCancel) && !forSubscription && orderID.isNotEmpty && orderID != '0') {
        bool actuallyPaid = await _verifyPaymentWithBackend(orderID);
        if (actuallyPaid) {
          isSuccess = true;
          isFailed = false;
          isCancel = false;
        }
      }

      close();

      if((addFundUrl == null || addFundUrl!.isEmpty) && (subscriptionUrl == null || subscriptionUrl!.isEmpty)){
        _orderPaymentDoneDecision(isSuccess, isFailed, isCancel);
      } else{
        _decideSubscriptionOrWallet(isSuccess, isFailed, isCancel, restaurantId, packageId);
      }
    }
  }

  void _orderPaymentDoneDecision(bool isSuccess, bool isFailed, bool isCancel) {
    if (isSuccess) {
      Get.find<CheckoutController>().sendCheckoutNotification(orderID);
      Get.find<CartController>().clearCartList();

      double total = ((orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
      Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));
      Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'success', orderAmount, contactNumber, isDeliveryOrder: isDeliveryOrder));
    } else if (isFailed || isCancel) {
      // Do not automatically cancel the order in the database.
      Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'fail', orderAmount, contactNumber, isDeliveryOrder: isDeliveryOrder));
    }
  }

  void _decideSubscriptionOrWallet(bool isSuccess, bool isFailed, bool isCancel, int? restaurantId, int? packageId) {
    if(isSuccess || isFailed || isCancel) {
      if(Get.currentRoute.contains(RouteHelper.payment)) {
        Get.back();
      }
      if(subscriptionUrl != null && subscriptionUrl!.isNotEmpty && addFundUrl == '' && addFundUrl!.isEmpty) {
        Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(true);
        Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(true);
        Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
          status: isSuccess ? 'success' : isFailed ? 'fail' : 'cancel',
          fromSubscription: true, restaurantId: restaurantId, packageId: packageId,
        ));
      } else {
        Get.back();
        Get.offAllNamed(RouteHelper.getWalletRoute(fundStatus: isSuccess ? 'success' : isFailed ? 'fail' : 'cancel', /*token: UniqueKey().toString()*/));
      }
    }
  }

}