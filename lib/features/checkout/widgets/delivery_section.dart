import 'package:stackfood_multivendor/features/checkout/controllers/checkout_controller.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/checkout/widgets/delivery_info_fields.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliverySection extends StatelessWidget {
  final CheckoutController checkoutController;
  final LocationController locationController;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  const DeliverySection({super.key, required this.checkoutController,
    required this.locationController, required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController, required this.guestNumberNode, required this.guestEmailController, required this.guestEmailNode});

  @override
  Widget build(BuildContext context) {
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    bool takeAway = (checkoutController.orderType == 'take_away');
    bool isDineIn = (checkoutController.orderType == 'dine_in');
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(children: [
      isGuestLoggedIn || isDineIn ? DeliveryInfoFields(
        checkoutController: checkoutController, guestNumberNode: guestNumberNode,
        guestNameTextEditingController: guestNameTextEditingController,
        guestNumberTextEditingController: guestNumberTextEditingController,
        guestEmailController: guestEmailController, guestEmailNode: guestEmailNode,
      ) : !takeAway && !isDineIn ? Container(
        margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : Dimensions.fontSizeDefault),
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('deliver_to'.tr, style: robotoMedium),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          !ResponsiveHelper.isDesktop(context) ? CustomTextFieldWidget(
            hintText: 'write_street_number'.tr == 'write_street_number' ? 'Enter your address' : 'write_street_number'.tr,
            labelText: 'street_number'.tr == 'street_number' || 'street_number'.tr == 'Add Locality' ? 'Your Address' : 'street_number'.tr,
            required: true,
            inputType: TextInputType.streetAddress,
            focusNode: checkoutController.streetNode,
            nextFocus: checkoutController.houseNode,
            controller: checkoutController.streetNumberController,
          ) : const SizedBox(),
          SizedBox(height: !ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0),

          Row(
            children: [
              ResponsiveHelper.isDesktop(context) ? Expanded(
                child: CustomTextFieldWidget(
                  hintText: 'write_street_number'.tr == 'write_street_number' ? 'Enter your address' : 'write_street_number'.tr,
                  labelText: 'street_number'.tr == 'street_number' || 'street_number'.tr == 'Add Locality' ? 'Your Address' : 'street_number'.tr,
                  required: true,
                  inputType: TextInputType.streetAddress,
                  focusNode: checkoutController.streetNode,
                  nextFocus: checkoutController.houseNode,
                  controller: checkoutController.streetNumberController,
                  showTitle: false,
                ),
              ) : const SizedBox(),
              SizedBox(width: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

              Expanded(
                child: CustomTextFieldWidget(
                  hintText: 'write_house_number'.tr,
                  labelText: 'house'.tr,
                  required: false,
                  inputType: TextInputType.text,
                  focusNode: checkoutController.houseNode,
                  nextFocus: checkoutController.floorNode,
                  controller: checkoutController.houseController,
                  showTitle: false,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Expanded(
                child: CustomTextFieldWidget(
                  hintText: 'write_floor_number'.tr,
                  labelText: 'floor'.tr,
                  required: false,
                  inputType: TextInputType.text,
                  focusNode: checkoutController.floorNode,
                  inputAction: TextInputAction.done,
                  controller: checkoutController.floorController,
                  showTitle: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        ]),
      ) : const SizedBox(),
    ]);
  }
}
