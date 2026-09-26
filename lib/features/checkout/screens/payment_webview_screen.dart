import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/api/api_client.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/location/domain/models/zone_response_model.dart';
import 'package:stackfood_multivendor/features/loyalty/controllers/loyalty_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/wallet/widgets/fund_payment_dialog_widget.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/helper/upi_payment_helper.dart';
import 'package:stackfood_multivendor/util/app_constants.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final OrderModel orderModel;
  final String paymentMethod;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String guestId;
  final String contactNumber;
  final int? restaurantId;
  final int? packageId;

  const PaymentWebViewScreen({
    super.key,
    required this.orderModel,
    required this.paymentMethod,
    this.addFundUrl,
    this.subscriptionUrl,
    required this.guestId,
    required this.contactNumber,
    this.restaurantId,
    this.packageId,
  });

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentWebViewScreen> with WidgetsBindingObserver {
  late String selectedUrl;
  bool _isLoading = true;
  bool _canRedirect = true;
  bool _isAwaitingUpiReturn = false;
  bool _isVerifyingPayment = false;
  double? _maximumCodOrderAmount;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;

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

    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      selectedUrl =
          '${AppConstants.baseUrl}/payment-mobile?customer_id=$customerId&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
    } else if (widget.subscriptionUrl != null && widget.subscriptionUrl!.isNotEmpty) {
      selectedUrl = widget.subscriptionUrl!;
    } else {
      selectedUrl = widget.addFundUrl!;
    }

    _initData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isAwaitingUpiReturn && !_isVerifyingPayment && _canRedirect) {
      if (kDebugMode) {
        print('User returned from external UPI app. Initiating payment verification...');
      }
      _verifyPaymentStatusAfterUpi();
    }
  }

  void _initData() async {
    if (widget.addFundUrl == null || widget.addFundUrl!.isEmpty) {
      final address = AddressHelper.getAddressFromSharedPref();
      if (address?.zoneData != null && widget.orderModel.restaurant?.zoneId != null) {
        try {
          ZoneData zoneData = address!.zoneData!.firstWhere(
            (data) => data.id == widget.orderModel.restaurant!.zoneId,
          );
          _maximumCodOrderAmount = zoneData.maxCodOrderAmount;
        } catch (_) {}
      }
    }

    pullToRefreshController = GetPlatform.isWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android].contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            onRefresh: () async {
              _resetPaymentWebview();
            },
          );
  }

  Future<bool> _verifyPaymentWithBackend(String orderId) async {
    bool isPaid = false;

    // 1. If payment method is Paytm, actively query backend getTxnStatus check API
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

  Future<void> _verifyPaymentStatusAfterUpi() async {
    if (!_canRedirect || !mounted) return;

    // Immediately dismiss Paytm's processing sheet via JavaScript
    _dismissPaytmProcessingModal();

    final orderId = widget.orderModel.id;
    bool isPaid = false;
    if (orderId != null && orderId != 0) {
      // Fast check after 500ms
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_canRedirect || !mounted) return;

      try {
        isPaid = await _verifyPaymentWithBackend(orderId.toString());
        if (isPaid && mounted && _canRedirect) {
          if (kDebugMode) {
            print('Payment confirmed as PAID by backend verification!');
          }
          _redirect(
            '${AppConstants.baseUrl}/payment-success',
            widget.contactNumber,
            widget.restaurantId,
            widget.packageId,
          );
          return;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error checking payment status on resume: $e');
        }
      }
    }

    _isAwaitingUpiReturn = false;

    // If no payment was processed, reset/reload the payment webview immediately
    // so the stuck "Processing Your Payment" modal sheet from Paytm disappears
    // and payment options become clickable again!
    if (!isPaid && mounted && _canRedirect) {
      if (kDebugMode) {
        print('Payment was not processed. Resetting webview to clear stuck processing modal...');
      }
      _resetPaymentWebview();
    }
  }

  void _dismissPaytmProcessingModal() async {
    try {
      await webViewController?.evaluateJavascript(source: """
        (function() {
          // 1. Dispatch Escape key to dismiss dialogs
          document.dispatchEvent(new KeyboardEvent('keydown', {'key': 'Escape', 'keyCode': 27, 'which': 27, 'bubbles': true}));

          // 2. Find and trigger close/cross buttons or back arrow in page
          var closeBtns = document.querySelectorAll('button, a, div, span, img, svg');
          for (var i = 0; i < closeBtns.length; i++) {
            var el = closeBtns[i];
            var cls = (el.className || '').toString().toLowerCase();
            var id = (el.id || '').toString().toLowerCase();
            var aria = (el.getAttribute('aria-label') || '').toLowerCase();
            if (cls.includes('close') || cls.includes('cancel') || cls.includes('cross') || id.includes('close') || aria.includes('close')) {
              if (el.offsetParent !== null) {
                el.click();
              }
            }
          }

          // 3. Remove/hide processing modal sheet and any related container
          var allEls = document.querySelectorAll('div, section, article, dialog');
          for (var j = 0; j < allEls.length; j++) {
            var node = allEls[j];
            if (node.innerText && node.innerText.indexOf('Processing Your Payment') !== -1) {
              var parent = node;
              while (parent && parent !== document.body && parent !== document.documentElement) {
                var s = window.getComputedStyle(parent);
                if (s.position === 'fixed' || s.position === 'absolute' || (parent.className && typeof parent.className === 'string' && (parent.className.toLowerCase().includes('sheet') || parent.className.toLowerCase().includes('modal') || parent.className.toLowerCase().includes('drawer') || parent.className.toLowerCase().includes('popup')))) {
                  parent.style.display = 'none';
                  try { parent.remove(); } catch(e) {}
                  break;
                }
                parent = parent.parentElement;
              }
              node.style.display = 'none';
            }
          }

          // 4. Remove all dark backdrops, overlays, and masks
          var backdropEls = document.querySelectorAll('div, span');
          for (var k = 0; k < backdropEls.length; k++) {
            var bEl = backdropEls[k];
            var bCls = (bEl.className || '').toString().toLowerCase();
            var bId = (bEl.id || '').toString().toLowerCase();
            if (bCls.includes('backdrop') || bCls.includes('overlay') || bCls.includes('dimmer') || bCls.includes('mask') || bId.includes('backdrop') || bId.includes('overlay')) {
              var bs = window.getComputedStyle(bEl);
              if (bs.position === 'fixed' || bs.position === 'absolute') {
                bEl.style.display = 'none';
                try { bEl.remove(); } catch(e) {}
              }
            }
          }

          // 5. Restore page interactivity and scroll
          if (document.body) {
            document.body.style.overflow = 'auto';
            document.body.style.pointerEvents = 'auto';
          }
          if (document.documentElement) {
            document.documentElement.style.overflow = 'auto';
            document.documentElement.style.pointerEvents = 'auto';
          }
        })();
      """);
    } catch (_) {}
  }

  Future<void> _resetPaymentWebview() async {
    try {
      _dismissPaytmProcessingModal();
      if (webViewController != null) {
        await webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(selectedUrl)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting payment webview: $e');
      }
      try {
        await webViewController?.reload();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          bool isModalActive = false;
          try {
            final res = await webViewController?.evaluateJavascript(source: """
              (function() {
                var text = document.body ? document.body.innerText : '';
                return text.indexOf('Processing Your Payment') !== -1;
              })();
            """);
            if (res == true || res == 'true') {
              isModalActive = true;
            }
          } catch (_) {}

          if (isModalActive) {
            _dismissPaytmProcessingModal();
            _resetPaymentWebview();
            return;
          }

          if (await webViewController?.canGoBack() ?? false) {
            webViewController?.goBack();
            return;
          }

          _exitApp();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBarWidget(
          title: 'payment'.tr,
          onBackPressed: () => _exitApp(),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => _resetPaymentWebview(),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
          ],
        ),
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(selectedUrl)),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              pullToRefreshController: pullToRefreshController,
              initialSettings: InAppWebViewSettings(
                useHybridComposition: true,
                useShouldOverrideUrlLoading: true,
                userAgent: GetPlatform.isIOS
                    ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1'
                    : 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                domStorageEnabled: true,
                supportMultipleWindows: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStart: (controller, url) async {
                _redirect(url.toString(), widget.contactNumber, widget.restaurantId, widget.packageId);
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                  });
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                Uri? uri = navigationAction.request.url;
                if (uri != null) {
                  String urlString = uri.toString();
                  if (kDebugMode) {
                    print('shouldOverrideUrlLoading: $urlString');
                  }

                  if (urlString.startsWith(AppConstants.baseUrl)) {
                    _redirect(urlString, widget.contactNumber, widget.restaurantId, widget.packageId);
                    return NavigationActionPolicy.ALLOW;
                  }

                  // Handle all UPI, smart intent, and custom schemes
                  if (UpiPaymentHelper.isUpiOrIntentUrl(urlString, uri)) {
                    _isAwaitingUpiReturn = true;
                    bool launched = await UpiPaymentHelper.launchUpiPayment(urlString);
                    if (!launched) {
                      _isAwaitingUpiReturn = false;
                      _resetPaymentWebview();
                    }
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
                _redirect(url.toString(), widget.contactNumber, widget.restaurantId, widget.packageId);
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();
                }
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint(consoleMessage.message);
              },
            ),

            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              ),

            // Sleek overlay when verifying payment after returning from UPI app
          ],
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    // If order was created, verify status with backend before exiting
    if (widget.orderModel.id != null && widget.orderModel.id != 0) {
      if (widget.addFundUrl != null && widget.addFundUrl!.isNotEmpty ||
          widget.subscriptionUrl != null && widget.subscriptionUrl!.isNotEmpty) {
        return _proceedToFailDialog();
      }

      return await Get.dialog<bool>(
        Builder(
          builder: (dialogContext) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              insetPadding: const EdgeInsets.all(30),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.payment, size: 55, color: Theme.of(dialogContext).primaryColor),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      'Exit Payment?',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'Your order is saved as pending. You can continue payment anytime from Order Details.',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    CustomButtonWidget(
                      buttonText: 'Continue in Payment',
                      onPressed: () => Get.back(result: false),
                      height: 40,
                      radius: Dimensions.radiusSmall,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    TextButton(
                      onPressed: () {
                        Get.back(result: false);
                        Get.offAllNamed(RouteHelper.getOrderDetailsRoute(
                          widget.orderModel.id,
                          contactNumber: widget.contactNumber,
                        ));
                      },
                      child: Text(
                        'Go to Order Details',
                        style: robotoMedium.copyWith(color: Theme.of(dialogContext).primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return _proceedToFailDialog();
  }

  Future<bool?> _proceedToFailDialog() async {
    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      return Get.dialog(
        PaymentFailedDialog(
          orderID: widget.orderModel.id.toString(),
          orderAmount: widget.orderModel.orderAmount,
          maxCodOrderAmount: _maximumCodOrderAmount,
          contactPersonNumber: widget.contactNumber,
        ),
        barrierDismissible: false,
      );
    } else {
      return Get.dialog(
        FundPaymentDialogWidget(
          isSubscription: widget.subscriptionUrl != null && widget.subscriptionUrl!.isNotEmpty,
        ),
      );
    }
  }

  void _redirect(String url, String? contactNumber, int? restaurantId, int? packageId) async {
    if (_canRedirect) {
      bool isSuccess = (url.startsWith('${AppConstants.baseUrl}/payment-success') ||
          url.startsWith('${AppConstants.baseUrl}/subscription-success'));
      bool isFailed = (url.startsWith('${AppConstants.baseUrl}/payment-fail') ||
          url.startsWith('${AppConstants.baseUrl}/subscription-fail'));
      bool isCancel = (url.startsWith('${AppConstants.baseUrl}/payment-cancel') ||
          url.startsWith('${AppConstants.baseUrl}/subscription-cancel'));

      if (!isSuccess && !isFailed && !isCancel) return;

      _canRedirect = false;

      // If gateway signaled failure or cancel, double check backend before treating as failed
      if ((isFailed || isCancel) &&
          (widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
          (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
        final orderId = widget.orderModel.id;
        if (orderId != null && orderId != 0) {
          bool actuallyPaid = await _verifyPaymentWithBackend(orderId.toString());
          if (actuallyPaid) {
            isSuccess = true;
            isFailed = false;
            isCancel = false;
          }
        }
      }

      if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
          (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
        if (isSuccess) {
          Get.find<CheckoutController>().sendCheckoutNotification(widget.orderModel.id.toString());
          Get.find<CartController>().clearCartList();

          double total = ((widget.orderModel.orderAmount! / 100) *
              Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
          Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));
          Get.offNamed(RouteHelper.getOrderSuccessRoute(
            widget.orderModel.id.toString(),
            'success',
            widget.orderModel.orderAmount,
            contactNumber,
            isDeliveryOrder: widget.orderModel.orderType == 'delivery',
          ));
        } else if (isFailed || isCancel) {
          // Do not cancel order in backend automatically.
          // Allow customer to switch to COD or explicitly cancel in dialog.
          Get.offNamed(RouteHelper.getOrderSuccessRoute(
            widget.orderModel.id.toString(),
            'fail',
            widget.orderModel.orderAmount,
            contactNumber,
            isDeliveryOrder: widget.orderModel.orderType == 'delivery',
          ));
        }
      } else {
        if (isSuccess || isFailed || isCancel) {
          if (Get.currentRoute.contains(RouteHelper.payment)) {
            Get.back();
          }
          if (widget.subscriptionUrl != null &&
              widget.subscriptionUrl!.isNotEmpty &&
              (widget.addFundUrl == null || widget.addFundUrl!.isEmpty)) {
            Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(true);
            Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(true);
            Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
              status: isSuccess ? 'success' : isFailed ? 'fail' : 'cancel',
              fromSubscription: true,
              restaurantId: restaurantId,
              packageId: packageId,
            ));
          } else {
            Get.back();
            Get.offAllNamed(RouteHelper.getWalletRoute(
              fundStatus: isSuccess ? 'success' : isFailed ? 'fail' : 'cancel',
            ));
          }
        }
      }
    }
  }
}