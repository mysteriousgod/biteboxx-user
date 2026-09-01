import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/payment_method_bottom_sheet.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSection extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final bool isOfflinePaymentActive;
  final double total;
  final CheckoutController checkoutController;
  const PaymentSection({
    super.key,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.checkoutController,
    required this.isOfflinePaymentActive,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      double walletBalance = Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;
      final splashController = Get.find<SplashController>();
      final config = splashController.configModel;
      final List<PaymentBody> activePaymentMethodList = config?.activePaymentMethodList ?? [];
      bool isGuest = Get.find<AuthController>().isGuestLoggedIn();

      bool showCod = isCashOnDeliveryActive;
      bool showDigital = isDigitalPaymentActive && !checkoutController.subscriptionOrder;
      bool showWallet = isWalletActive && !checkoutController.subscriptionOrder && !isGuest && (walletBalance > 0);
      bool showOffline = isOfflinePaymentActive && !checkoutController.subscriptionOrder && !checkoutController.isPartialPay;

      if (checkoutController.isPartialPay) {
        showWallet = false;
        String? partialMethod = config?.partialPaymentMethod;
        if (partialMethod == 'cod') {
          showDigital = false;
        } else if (partialMethod == 'digital_payment') {
          showCod = false;
        }
      }

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ),
        margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.fontSizeDefault),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('payment_method'.tr, style: robotoMedium),

            InkWell(
              onTap: () {
                if (ResponsiveHelper.isDesktop(context)) {
                  Get.dialog(Dialog(backgroundColor: Colors.transparent, child: PaymentMethodBottomSheet(
                    isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                    isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
                  )));
                } else {
                  Get.bottomSheet(
                    PaymentMethodBottomSheet(
                      isCashOnDeliveryActive: isCashOnDeliveryActive, isDigitalPaymentActive: isDigitalPaymentActive,
                      isWalletActive: isWalletActive, totalPrice: total, isOfflinePaymentActive: isOfflinePaymentActive,
                    ),
                    backgroundColor: Colors.transparent, isScrollControlled: true, useRootNavigator: true,
                  );
                }
              },
              child: Image.asset(Images.paymentSelect, height: 22, width: 22),
            ),
          ]),

          const Divider(),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          // If partial pay is active, show wallet portion applied banner
          if (checkoutController.isPartialPay) ...[
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Image.asset(Images.wallet, width: 18, height: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text('paid_by_wallet'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                ]),
                Row(children: [
                  Text(
                    PriceConverter.convertPrice(walletBalance),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  InkWell(
                    onTap: () {
                      checkoutController.changePartialPayment();
                      checkoutController.setPaymentMethod(-1);
                    },
                    child: Icon(Icons.cancel, size: 18, color: Theme.of(context).colorScheme.error),
                  ),
                ]),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  '${'remaining_bill'.tr} (${'due'.tr}):',
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                Text(
                  PriceConverter.convertPrice(total - walletBalance),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                ),
              ]),
            ),
          ],

          // Payment Option: Cash on Delivery
          if (showCod)
            _buildPaymentOptionTile(
              context: context,
              title: 'cash_on_delivery'.tr,
              assetIcon: Images.cash,
              isSelected: checkoutController.paymentMethodIndex == 0,
              onTap: () {
                checkoutController.setPaymentMethod(0);
              },
            ),

          // Payment Option: Digital Payments
          if (showDigital) ...[
            if (activePaymentMethodList.isNotEmpty)
              ...activePaymentMethodList.map((paymentBody) {
                bool isSelected = checkoutController.paymentMethodIndex == 2 &&
                    checkoutController.digitalPaymentName == paymentBody.getWay;
                return _buildPaymentOptionTile(
                  context: context,
                  title: paymentBody.getWayTitle ?? 'pay_via_online'.tr,
                  networkImage: paymentBody.getWayImageFullUrl,
                  isSelected: isSelected,
                  onTap: () {
                    checkoutController.setPaymentMethod(2);
                    if (paymentBody.getWay != null) {
                      checkoutController.changeDigitalPaymentName(paymentBody.getWay!);
                    }
                  },
                );
              })
            else
              _buildPaymentOptionTile(
                context: context,
                title: 'pay_via_online'.tr,
                assetIcon: Images.digitalPayment,
                isSelected: checkoutController.paymentMethodIndex == 2,
                onTap: () {
                  checkoutController.setPaymentMethod(2);
                },
              ),
          ],

          // Payment Option: Wallet
          if (showWallet)
            _buildPaymentOptionTile(
              context: context,
              title: 'wallet_payment'.tr,
              subtitle: '${'wallet_balance'.tr}: ${PriceConverter.convertPrice(walletBalance)}',
              assetIcon: Images.wallet,
              isSelected: checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay,
              onTap: () {
                if (walletBalance >= total) {
                  checkoutController.setPaymentMethod(1);
                } else if (config?.partialPaymentStatus == true) {
                  checkoutController.changePartialPayment();
                  checkoutController.setPaymentMethod(1);
                } else {
                  checkoutController.setPaymentMethod(1);
                }
              },
            ),

          // Payment Option: Offline Payment
          if (showOffline) ...[
            _buildPaymentOptionTile(
              context: context,
              title: 'pay_offline'.tr,
              iconData: Icons.account_balance_outlined,
              isSelected: checkoutController.paymentMethodIndex == 3,
              onTap: () {
                checkoutController.setPaymentMethod(3);
              },
            ),
            if (checkoutController.paymentMethodIndex == 3 &&
                checkoutController.offlineMethodList != null &&
                checkoutController.offlineMethodList!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Wrap(
                  spacing: Dimensions.paddingSizeSmall,
                  runSpacing: Dimensions.paddingSizeSmall,
                  children: List.generate(checkoutController.offlineMethodList!.length, (index) {
                    bool isBankSelected = checkoutController.selectedOfflineBankIndex == index;
                    return InkWell(
                      onTap: () => checkoutController.selectOfflineBank(index),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          color: isBankSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          border: Border.all(color: isBankSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          checkoutController.offlineMethodList![index].methodName ?? '',
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: isBankSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],

          // Warning if no payment method selected
          if (checkoutController.paymentMethodIndex == -1)
            Padding(
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [
                Icon(Icons.error_outline, size: 16, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  'select_payment_method'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ]),
            ),
        ]),
      );
    });
  }

  Widget _buildPaymentOptionTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    String? assetIcon,
    String? networkImage,
    IconData? iconData,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color cardColor = Theme.of(context).cardColor;
    final Color disabledColor = Theme.of(context).disabledColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withValues(alpha: 0.05) : cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            border: Border.all(
              color: isSelected ? primaryColor : disabledColor.withValues(alpha: 0.25),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeSmall + 2,
          ),
          child: Row(
            children: [
              if (networkImage != null && networkImage.isNotEmpty)
                CustomImageWidget(
                  height: 22,
                  width: 36,
                  fit: BoxFit.contain,
                  image: networkImage,
                )
              else if (assetIcon != null)
                Image.asset(
                  assetIcon,
                  width: 22,
                  height: 22,
                  color: isSelected ? primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                )
              else if (iconData != null)
                Icon(
                  iconData,
                  size: 22,
                  color: isSelected ? primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isSelected
                            ? (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black)
                            : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87),
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: disabledColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: 22,
                color: isSelected ? primaryColor : disabledColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

