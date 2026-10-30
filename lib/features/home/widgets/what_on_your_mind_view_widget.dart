import 'package:carousel_slider/carousel_slider.dart';
import 'package:stackfood_multivendor/common/widgets/custom_ink_well_widget.dart';
import 'package:stackfood_multivendor/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/category/controllers/category_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WhatOnYourMindViewWidget extends StatefulWidget {
  const WhatOnYourMindViewWidget({super.key});

  @override
  State<WhatOnYourMindViewWidget> createState() => _WhatOnYourMindViewWidgetState();
}

class _WhatOnYourMindViewWidgetState extends State<WhatOnYourMindViewWidget> {
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      return (categoryController.categoryList != null && categoryController.categoryList!.isNotEmpty) ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeOverLarge,
              left: Get.find<LocalizationController>().isLtr ? Dimensions.paddingSizeExtraSmall : 0,
              right: Get.find<LocalizationController>().isLtr ? 0 : Dimensions.paddingSizeExtraSmall,
              bottom: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeOverLarge,
            ),
            child: ResponsiveHelper.isDesktop(context) ? Text('what_on_your_mind'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)) :
            Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('what_on_your_mind'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600)),
                  ArrowIconButtonWidget(onTap: () => Get.toNamed(RouteHelper.getCategoryRoute())),
                ],
              ),
            ),
          ),

          Row(
            children: [
              ResponsiveHelper.isDesktop(context) ? ArrowIconButtonWidget(
                isLeft: true,
                onTap: () => _carouselController.previousPage(),
              ) : const SizedBox(),

              Expanded(
                child: categoryController.categoryList != null ? SizedBox(
                  height: ResponsiveHelper.isMobile(context) ? 145 : 175,
                  child: CarouselSlider.builder(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: ResponsiveHelper.isMobile(context) ? 145 : 175,
                      viewportFraction: ResponsiveHelper.isDesktop(context) ? 0.11 : 0.26,
                      enableInfiniteScroll: categoryController.categoryList!.length > (ResponsiveHelper.isDesktop(context) ? 9 : 3),
                      padEnds: false,
                      enlargeCenterPage: false,
                      autoPlay: categoryController.categoryList!.length > (ResponsiveHelper.isDesktop(context) ? 9 : 3),
                      autoPlayInterval: const Duration(seconds: 4),
                      autoPlayAnimationDuration: const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      disableCenter: true,
                    ),
                    itemCount: categoryController.categoryList!.length,
                    itemBuilder: (context, index, _) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall),
                        child: CustomInkWellWidget(
                          onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                            categoryController.categoryList![index].id,
                            categoryController.categoryList![index].name!,
                          )),
                          radius: Dimensions.radiusDefault,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  child: CustomImageWidget(
                                    image: '${categoryController.categoryList![index].imageFullUrl}',
                                    height: ResponsiveHelper.isMobile(context) ? 88 : 105,
                                    width: ResponsiveHelper.isMobile(context) ? 88 : 105,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              Text(
                                categoryController.categoryList![index].name!,
                                style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ) : WebWhatOnYourMindViewShimmer(categoryController: categoryController),
              ),

              ResponsiveHelper.isDesktop(context) ? ArrowIconButtonWidget(
                onTap: () => _carouselController.nextPage(),
              ) : const SizedBox(),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ) : const SizedBox();
    });
  }
}

class WebWhatOnYourMindViewShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const WebWhatOnYourMindViewShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ResponsiveHelper.isMobile(context) ? 145 : 175,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeSmall),
            child: Container(
              width: ResponsiveHelper.isMobile(context) ? 88 : 105,
              height: ResponsiveHelper.isMobile(context) ? 88 : 105,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              margin: EdgeInsets.only(top: ResponsiveHelper.isMobile(context) ? 0 : Dimensions.paddingSizeSmall),
              child: Column(children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  child: Shimmer(
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), color: Theme.of(context).shadowColor),
                      height: ResponsiveHelper.isMobile(context) ? 88 : 105,
                      width: ResponsiveHelper.isMobile(context) ? 88 : 105,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: Shimmer(
                    child: Container(
                      height: ResponsiveHelper.isMobile(context) ? 10 : 15,
                      width: 70,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Theme.of(context).shadowColor),
                    ),
                  ),
                ),

              ]),
            ),
          );
        },
      ),
    );
  }
}
