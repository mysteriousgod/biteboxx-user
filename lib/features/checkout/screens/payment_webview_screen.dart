import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:stackfood_multivendor/features/dashboard/controllers/dashboard_controller.dart';
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

    if ((widget.addFundUrl == null || widget.addFundUrl!.isEmpty) &&
        (widget.subscriptionUrl == null || widget.subscriptionUrl!.isEmpty)) {
      selectedUrl =
          '${AppConstants.baseUrl}/payment-mobile?customer_id=${widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId}&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
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
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(url: await webViewController?.getUrl()),
                );
              }
            },
          );
  }

  Future<void> _verifyPaymentStatusAfterUpi() async {
    if (!_canRedirect || !mounted) return;

    setState(() {
      _isVerifyingPayment = true;
    });

    // Check backend status in a loop (up to 6 times with 2.5s delay = 15s)
    final orderId = widget.orderModel.id;
    if (orderId != null && orderId != 0) {
      for (int i = 0; i < 6; i++) {
        if (!_canRedirect || !mounted) break;
        await Future.delayed(const Duration(milliseconds: 2500));

        try {
          final orderController = Get.find<OrderController>();
          await orderController.trackOrder(
            orderId.toString(),
            null,
            false,
            contactNumber: widget.contactNumber,
          );

          if (orderController.trackModel?.paymentStatus == 'paid') {
            if (kDebugMode) {
              print('UPI payment confirmed as PAID by backend verification!');
            }
            if (mounted) {
              setState(() {
                _isVerifyingPayment = false;
                _isAwaitingUpiReturn = false;
              });
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
    }

    if (mounted) {
      setState(() {
        _isVerifyingPayment = false;
      });
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
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBarWidget(title: 'payment'.tr, onBackPressed: () => _exitApp()),
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
                    await UpiPaymentHelper.launchUpiPayment(urlString);
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
            if (_isVerifyingPayment)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeExtraLarge,
                      vertical: Dimensions.paddingSizeLarge,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Text(
                          'verifying_payment'.tr.isNotEmpty ? 'verifying_payment'.tr : 'Verifying your payment...',
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          'please_do_not_close_app'.tr.isNotEmpty
                              ? 'please_do_not_close_app'.tr
                              : 'Please wait while we confirm your payment with the bank. Do not close or press back.',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).disabledColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _exitApp() async {
    if (_isVerifyingPayment) {
      Get.snackbar(
        'payment_in_progress'.tr.isNotEmpty ? 'payment_in_progress'.tr : 'Payment in Progress',
        'verifying_payment_msg'.tr.isNotEmpty
            ? 'verifying_payment_msg'.tr
            : 'Please wait while we verify your transaction status with your bank.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // If external UPI app was opened, verify status once before showing fail dialog
    if (_isAwaitingUpiReturn && widget.orderModel.id != null && widget.orderModel.id != 0) {
      try {
        final orderController = Get.find<OrderController>();
        await orderController.trackOrder(
          widget.orderModel.id.toString(),
          null,
          false,
          contactNumber: widget.contactNumber,
        );
        if (orderController.trackModel?.paymentStatus == 'paid') {
          _redirect(
            '${AppConstants.baseUrl}/payment-success',
            widget.contactNumber,
            widget.restaurantId,
            widget.packageId,
          );
          return true;
        }
      } catch (_) {}

      if (!mounted) return false;

      // Prompt user with confirmation so they don't accidentally cancel a paid order
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
                    Icon(Icons.help_outline, size: 60, color: Theme.of(dialogContext).primaryColor),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Text(
                      'Have you completed your UPI payment?',
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(
                      'If money was debited from your account, tap "Verify Payment". If you cancelled in the UPI app, tap "Exit".',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    CustomButtonWidget(
                      buttonText: 'Verify Payment',
                      onPressed: () {
                        Get.back(result: false);
                        _verifyPaymentStatusAfterUpi();
                      },
                      height: 40,
                      radius: Dimensions.radiusSmall,
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    TextButton(
                      onPressed: () {
                        Get.back(result: false);
                        _proceedToFailDialog();
                      },
                      child: Text(
                        'Exit Payment',
                        style: robotoMedium.copyWith(color: Theme.of(dialogContext).colorScheme.error),
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

  void _redirect(String url, String? contactNumber, int? restaurantId, int? packageId) {
    if (_canRedirect) {
      bool isSuccess = url.contains('success') && url.startsWith(AppConstants.baseUrl);
      bool isFailed = url.contains('fail') && url.startsWith(AppConstants.baseUrl);
      bool isCancel = url.contains('cancel') && url.startsWith(AppConstants.baseUrl);
      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
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
          Get.find<OrderController>().cancelOrder(widget.orderModel.id, 'Payment failed or cancelled');
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