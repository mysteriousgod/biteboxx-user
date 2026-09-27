import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/auth_helper.dart';
import 'package:stackfood_multivendor/helper/price_converter.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class ChangeOrderAddressBottomSheet extends StatefulWidget {
  final OrderModel order;
  const ChangeOrderAddressBottomSheet({super.key, required this.order});

  @override
  State<ChangeOrderAddressBottomSheet> createState() => _ChangeOrderAddressBottomSheetState();
}

class _ChangeOrderAddressBottomSheetState extends State<ChangeOrderAddressBottomSheet> {
  AddressModel? _selectedAddress;
  Map<String, dynamic>? _previewData;
  bool _isChecking = false;
  String _paymentOption = 'doorstep';

  @override
  void initState() {
    super.initState();
    Get.find<AddressController>().getAddressList();
  }

  Future<void> _checkAddress(AddressModel address) async {
    setState(() {
      _selectedAddress = address;
      _isChecking = true;
      _previewData = null;
    });

    final preview = await Get.find<OrderController>().checkAddressChange(
      widget.order.id!,
      double.parse(address.latitude ?? '0'),
      double.parse(address.longitude ?? '0'),
      address.address ?? '',
    );

    if (mounted) {
      setState(() {
        _isChecking = false;
        _previewData = preview;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
    AddressModel address = await Get.find<LocationController>().getCurrentLocation(true);
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    if (address.latitude != null && address.longitude != null) {
      await _checkAddress(address);
    } else {
      showCustomSnackBar('failed_to_fetch_current_location'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  height: 4, width: 40,
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'change_delivery_address'.tr == 'change_delivery_address' ? 'Change Delivery Address' : 'change_delivery_address'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Text(
                'select_new_drop_location'.tr == 'select_new_drop_location'
                    ? 'Select your new drop location. Extra distance fee will be credited directly to your delivery partner.'
                    : 'select_new_drop_location'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Use current location button
              InkWell(
                onTap: _useCurrentLocation,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.my_location, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Text(
                          'use_my_current_location'.tr == 'use_my_current_location' ? 'Use My Current Location' : 'use_my_current_location'.tr,
                          style: robotoMedium.copyWith(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Saved addresses header
              Text(
                'saved_addresses'.tr == 'saved_addresses' ? 'Saved Addresses' : 'saved_addresses'.tr,
                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // Saved addresses list
              GetBuilder<AddressController>(builder: (addressController) {
                if (addressController.addressList == null) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (addressController.addressList!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Text('no_saved_address_found'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addressController.addressList!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    final addr = addressController.addressList![index];
                    final isSelected = _selectedAddress?.id == addr.id;

                    return InkWell(
                      onTap: () => _checkAddress(addr),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.05) : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              addr.addressType == 'home' ? Icons.home : addr.addressType == 'office' ? Icons.work : Icons.location_on,
                              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                              size: 20,
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(addr.addressType?.capitalizeFirst ?? 'Address', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                  const SizedBox(height: 2),
                                  Text(
                                    addr.address ?? '',
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),

              // Calculation / Preview Card
              if (_isChecking)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (_previewData != null && !_isChecking) ...[
                const SizedBox(height: Dimensions.paddingSizeLarge),
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Distance Change:', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                          Text(
                            '${_previewData!['original_distance']} km ➔ ${_previewData!['new_distance']} km',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Extra Distance:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                          Text(
                            '+${_previewData!['extra_distance']} km',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.orange.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Extra Delivery Fee:', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          Text(
                            (_previewData!['extra_charge'] as num) > 0
                                ? '+${_previewData!['currency_symbol']}${_previewData!['extra_charge']}'
                                : 'FREE',
                            style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: (_previewData!['extra_charge'] as num) > 0 ? Theme.of(context).primaryColor : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.volunteer_activism, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '100% of this extra delivery charge is directly credited to your delivery partner for the extra distance.',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.green.shade800),
                            ),
                          ),
                        ],
                      ),

                      if ((_previewData!['extra_charge'] as num) > 0) ...[
                        const Divider(height: 24),
                        Text('Choose How to Pay Extra Fee:', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
                        const SizedBox(height: 8),

                        // Option 1: Doorstep (Cash or UPI to Rider)
                        InkWell(
                          onTap: () => setState(() => _paymentOption = 'doorstep'),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: _paymentOption == 'doorstep' ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(
                                color: _paymentOption == 'doorstep' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(children: [
                              Icon(
                                _paymentOption == 'doorstep' ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: _paymentOption == 'doorstep' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Pay at Doorstep (Cash / UPI)', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                Text('Pay directly to delivery partner upon arrival', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                              ])),
                            ]),
                          ),
                        ),

                        // Option 2: Pay Online Now
                        InkWell(
                          onTap: () => setState(() => _paymentOption = 'online'),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: _paymentOption == 'online' ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : Colors.transparent,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              border: Border.all(
                                color: _paymentOption == 'online' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(children: [
                              Icon(
                                _paymentOption == 'online' ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: _paymentOption == 'online' ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Pay Online Now', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                Text('Pay digitally via UPI / Netbanking / Cards', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor)),
                              ])),
                            ]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Confirm button
              GetBuilder<OrderController>(builder: (orderController) {
                String buttonText = 'Confirm & Update Address';
                if (orderController.isAddressUpdating) {
                  buttonText = 'Updating Address...';
                } else if (_previewData != null && (_previewData!['extra_charge'] as num) > 0) {
                  buttonText = _paymentOption == 'online'
                      ? 'Pay ${_previewData!['currency_symbol']}${_previewData!['extra_charge']} Online & Update'
                      : 'Confirm & Pay at Doorstep';
                }

                return CustomButtonWidget(
                  buttonText: buttonText,
                  isLoading: orderController.isAddressUpdating,
                  onPressed: (_selectedAddress != null && _previewData != null && !orderController.isAddressUpdating)
                      ? () async {
                          bool success = await orderController.updateDeliveryAddress(
                            widget.order.id!,
                            double.parse(_selectedAddress!.latitude ?? '0'),
                            double.parse(_selectedAddress!.longitude ?? '0'),
                            _selectedAddress!.address ?? '',
                            contactPersonName: _selectedAddress!.contactPersonName,
                            contactPersonNumber: _selectedAddress!.contactPersonNumber,
                            addressType: _selectedAddress!.addressType,
                            extraPaymentMethod: _paymentOption,
                          );
                          if (success && mounted) {
                            Navigator.pop(context);
                            if (_paymentOption == 'online' && (_previewData!['extra_charge'] as num) > 0) {
                              Get.toNamed(RouteHelper.getPaymentRoute(
                                widget.order,
                                'digital_payment',
                                guestId: AuthHelper.isLoggedIn() ? '' : AuthHelper.getGuestId(),
                              ));
                            }
                          }
                        }
                      : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
