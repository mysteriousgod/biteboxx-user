import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class DeliveryDetails extends StatelessWidget {
  final bool from;
  final String? address;
  const DeliveryDetails({super.key, this.from = true, this.address});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (from ? Colors.blue : Theme.of(context).primaryColor).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          from ? Icons.storefront_rounded : Icons.location_on_rounded,
          size: 20,
          color: from ? Colors.blue : Theme.of(context).primaryColor,
        ),
      ),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(from ? 'from_restaurant'.tr : 'To'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall)),
        const SizedBox(height: 3),

        Text(
          address ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
        )
      ])),
    ]);
  }
}
