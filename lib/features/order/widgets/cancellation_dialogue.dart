import 'package:stackfood_multivendor/features/order/controllers/order_controller.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_cancellation_body.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CancellationDialogue extends StatefulWidget {
  final int? orderId;
  const CancellationDialogue({super.key, required this.orderId});

  @override
  State<CancellationDialogue> createState() => _CancellationDialogueState();
}

class _CancellationDialogueState extends State<CancellationDialogue> {
  final TextEditingController _customReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<OrderController>().getOrderCancelReasons();
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: GetBuilder<OrderController>(
        builder: (orderController) {
          List<CancellationData> reasons = (orderController.orderCancelReasons != null && orderController.orderCancelReasons!.isNotEmpty)
              ? orderController.orderCancelReasons!
              : OrderController.defaultCancellationReasons;

          // Auto-select first reason if none selected yet
          if (orderController.cancelReason == null || orderController.cancelReason!.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (reasons.isNotEmpty && mounted && (orderController.cancelReason == null || orderController.cancelReason!.isEmpty)) {
                orderController.setOrderCancelReason(reasons.first.reason);
              }
            });
          }

          bool isOtherSelected = orderController.cancelReason == 'Other reason' ||
              (orderController.cancelReason != null && orderController.cancelReason!.toLowerCase().contains('other'));

          return SizedBox(
            width: 500,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(children: [

              Container(
                width: 500,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                ),
                child: Column(children: [
                  Text('select_cancellation_reasons'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                ]),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [
                      ListView.builder(
                        itemCount: reasons.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isSelected = reasons[index].reason == orderController.cancelReason;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: InkWell(
                              onTap: () {
                                orderController.setOrderCancelReason(reasons[index].reason);
                              },
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                    Expanded(
                                      child: Text(
                                        reasons[index].reason ?? '',
                                        style: robotoRegular.copyWith(
                                          color: isSelected ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).disabledColor,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      if (isOtherSelected) ...[
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: TextField(
                            controller: _customReasonController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Please specify your reason...',
                              hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                borderSide: BorderSide(color: Theme.of(context).disabledColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                borderSide: BorderSide(color: Theme.of(context).primaryColor),
                              ),
                              contentPadding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.fontSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: !orderController.isCancelLoading ? Row(children: [
                  Expanded(child: CustomButtonWidget(
                    buttonText: 'cancel'.tr, color: Theme.of(context).disabledColor, radius: 50,
                    onPressed: () => Get.back(),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(child: CustomButtonWidget(
                    buttonText: 'submit'.tr, radius: 50,
                    onPressed: () {
                      String reason = orderController.cancelReason ?? '';
                      if (isOtherSelected && _customReasonController.text.trim().isNotEmpty) {
                        reason = _customReasonController.text.trim();
                      }

                      if (reason.isNotEmpty) {
                        orderController.cancelOrder(widget.orderId, reason).then((success) {
                          if (success && widget.orderId != null) {
                            orderController.trackOrder(widget.orderId.toString(), null, true);
                          }
                        });
                      } else {
                        showCustomSnackBar('you_did_not_select_select_any_reason'.tr);
                      }
                    },
                  )),
                ]) : const Center(child: CircularProgressIndicator()),
              ),
            ]),
          );
        },
      ),
    );
  }
}
