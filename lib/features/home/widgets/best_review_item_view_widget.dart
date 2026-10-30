import 'package:carousel_slider/carousel_slider.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/item_card_widget.dart';
import 'package:stackfood_multivendor/features/review/controllers/review_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BestReviewItemViewWidget extends StatefulWidget {
  final bool isPopular;
  const BestReviewItemViewWidget({super.key, required this.isPopular});

  @override
  State<BestReviewItemViewWidget> createState() => _BestReviewItemViewWidgetState();
}

class _BestReviewItemViewWidgetState extends State<BestReviewItemViewWidget> {
  final CarouselSliderController carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(builder: (reviewController) {
      return (reviewController.reviewedProductList != null && reviewController.reviewedProductList!.isEmpty) ? const SizedBox() : Padding(
        padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
        child: SizedBox(
          height: ResponsiveHelper.isMobile(context) ? 370 : 385,
          width: Dimensions.webMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : 0),
                child: Row(
                  children: [
                    Text('best_reviewed_food'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    ArrowIconButtonWidget(
                      onTap: () => Get.toNamed(RouteHelper.getPopularFoodRoute(widget.isPopular)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Row(children: [
                ResponsiveHelper.isDesktop(context) ? ArrowIconButtonWidget(
                  isLeft: true,
                  onTap: () => carouselController.previousPage(),
                ) : const SizedBox(),

                reviewController.reviewedProductList != null ? Expanded(
                  child: CarouselSlider.builder(
                    carouselController: carouselController,
                    options: CarouselOptions(
                      height: ResponsiveHelper.isMobile(context) ? 305 : 315,
                      viewportFraction: ResponsiveHelper.isDesktop(context) ? 0.2 : 0.54,
                      enlargeFactor: ResponsiveHelper.isDesktop(context) ? 0.2 : 0.2,
                      autoPlay: (reviewController.reviewedProductList!.length > 1),
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      disableCenter: true,
                    ),
                    itemCount: reviewController.reviewedProductList!.length,
                    itemBuilder: (context, index, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ItemCardWidget(
                          product: reviewController.reviewedProductList![index],
                          isBestItem: true,
                          isPopularNearbyItem: true,
                        ),
                      );
                    },
                  ),
                ) : const ItemCardShimmer(isPopularNearbyItem: true),

                ResponsiveHelper.isDesktop(context) ? ArrowIconButtonWidget(
                  onTap: () => carouselController.nextPage(),
                ) : const SizedBox(),
              ]),
            ],
          ),
        ),
      );
    });
  }
}
