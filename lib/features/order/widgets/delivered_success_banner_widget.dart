import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/order/domain/models/order_model.dart';
import 'package:stackfood_multivendor/helper/date_converter.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class DeliveredSuccessBannerWidget extends StatelessWidget {
  final OrderModel order;
  const DeliveredSuccessBannerWidget({super.key, required this.order});

  int? _calculateDeliveryMinutes() {
    if (order.delivered != null && order.createdAt != null) {
      try {
        DateTime deliveredDate = DateTime.parse(order.delivered!);
        DateTime createdDate = DateTime.parse(order.createdAt!);
        int diff = deliveredDate.difference(createdDate).inMinutes;
        if (diff > 0) return diff;
      } catch (_) {}
    }
    if (order.updatedAt != null && order.createdAt != null) {
      try {
        DateTime deliveredDate = DateTime.parse(order.updatedAt!);
        DateTime createdDate = DateTime.parse(order.createdAt!);
        int diff = deliveredDate.difference(createdDate).inMinutes;
        if (diff > 0) return diff;
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    int? deliveryMinutes = _calculateDeliveryMinutes();
    String celebrationHeadline = (deliveryMinutes != null && deliveryMinutes > 0)
        ? '🎉 YAY! DELIVERED IN $deliveryMinutes MINS! 🎉'
        : '🎉 ORDER DELIVERED SUCCESSFULLY! 🎉';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00C853), // Vibrant bright green
            Color(0xFF009624), // Rich emerald green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C853).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Decorative background circles for Instagram screenshot aesthetic
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeLarge,
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated checkmark badge
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    Images.checkGif,
                    height: 52,
                    width: 52,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // Main celebration headline
                Text(
                  celebrationHeadline,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    color: Colors.white,
                    fontSize: Dimensions.fontSizeExtraLarge,
                    letterSpacing: 0.4,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Fresh & hot, straight to you! Enjoy your meal 😋',
                  textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: 10),

                // Delivery timestamp chip
                if (order.delivered != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          '${'delivered_at'.tr}: ${DateConverter.dateTimeStringToDateTime(order.delivered!)}',
                          style: robotoMedium.copyWith(
                            color: Colors.white,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
