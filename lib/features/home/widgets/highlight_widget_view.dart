import 'package:carousel_slider/carousel_slider.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stackfood_multivendor/common/models/restaurant_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_asset_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_favourite_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/home/controllers/advertisement_controller.dart';
import 'package:stackfood_multivendor/features/home/domain/models/advertisement_model.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/restaurant/screens/restaurant_screen.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:video_player/video_player.dart';

class HighlightWidgetView extends StatefulWidget {
  const HighlightWidgetView({super.key});

  @override
  State<HighlightWidgetView> createState() => _HighlightWidgetViewState();
}

class _HighlightWidgetViewState extends State<HighlightWidgetView> {

  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return advertisementController.advertisementList != null && advertisementController.advertisementList!.isNotEmpty ? Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeDefault),
        child: Stack(
          children: [

            CustomAssetImageWidget(
              Images.highlightBg, width: context.width,
              fit: BoxFit.cover,
            ),

            Column(children: [

              Padding(
                padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault, bottom: Dimensions.paddingSizeExtraSmall,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('highlights_for_you'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black)),
                      const SizedBox(width: 5),

                      Text('see_our_most_popular_restaurant_and_foods'.tr, style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                    ],
                  ),

                  const CustomAssetImageWidget(
                    Images.highlightIcon, height: 50, width: 50,
                  ),

                ]),
              ),

              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: advertisementController.advertisementList!.length,
                options: CarouselOptions(
                  enableInfiniteScroll: advertisementController.advertisementList!.length > 2,
                  autoPlay: advertisementController.autoPlay,
                  enlargeCenterPage: false,
                  height: 280,
                  viewportFraction: 1,
                  disableCenter: true,
                  onPageChanged: (index, reason) {

                    advertisementController.setCurrentIndex(index, true);

                    if(advertisementController.advertisementList?[index].addType == "video_promotion"){
                      advertisementController.updateAutoPlayStatus(status: false);
                    }else{
                      advertisementController.updateAutoPlayStatus(status: true);
                    }

                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return advertisementController.advertisementList?[index].addType == 'video_promotion' ? HighlightVideoWidget(
                    advertisement: advertisementController.advertisementList![index],
                  ) : HighlightRestaurantWidget(advertisement: advertisementController.advertisementList![index]);
                },
              ),

              const AdvertisementIndicator(),

              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

            ]),
          ],
        ),
      ) : advertisementController.advertisementList == null ? const SizedBox() : const SizedBox();
    });
  }
}

class HighlightRestaurantWidget extends StatelessWidget {
  final AdvertisementModel advertisement;
  const HighlightRestaurantWidget({super.key, required this.advertisement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.07), width: 2),
      ),
      child: InkWell(
        onTap: (){
          Get.toNamed(RouteHelper.getRestaurantRoute(advertisement.restaurantId),
            arguments: RestaurantScreen(restaurant: Restaurant(id: advertisement.restaurantId)),
          );
        },
        child: Column(children: [

          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
              child: Stack(
                children: [
                  CustomImageWidget(
                    image: advertisement.coverImageFullUrl ?? '',
                    fit: BoxFit.cover, height: 160, width: double.infinity,
                  ),

                  (advertisement.isRatingActive == 1 || advertisement.isReviewActive == 1) ? Positioned(
                    right: 10, bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Theme.of(context).cardColor, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 0)],
                      ),
                      child: Row(
                        children: [
                          advertisement.isRatingActive == 1 ? Icon(Icons.star, color: Theme.of(context).cardColor, size: 15) : const SizedBox(),
                          SizedBox(width: advertisement.isRatingActive == 1 ? 5 : 0),

                          advertisement.isRatingActive == 1 ? Text('${advertisement.averageRating?.toStringAsFixed(1)}', style: robotoBold.copyWith(color: Theme.of(context).cardColor)) : const SizedBox(),
                          SizedBox(width: advertisement.isRatingActive == 1 ? 5 : 0),

                          advertisement.isReviewActive == 1 ? Text('(${advertisement.reviewsCommentsCount})', style: robotoRegular.copyWith(color: Theme.of(context).cardColor)) : const SizedBox(),
                        ],
                      ),
                    ),
                  ) : const SizedBox(),

                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 2),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      image: advertisement.profileImageFullUrl ?? '',
                      height: 60, width: 60, fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Flexible(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

                      Flexible(
                        child: Text(
                          advertisement.title ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis
                        ),
                      ),

                      GetBuilder<FavouriteController>(builder: (favouriteController) {
                        bool isWished = favouriteController.wishRestIdList.contains(advertisement.restaurantId);
                        return CustomFavouriteWidget(
                          isWished: isWished,
                          isRestaurant: true,
                          restaurantId: advertisement.restaurantId,
                        );
                      }),

                    ]),
                    const SizedBox(height: 3),

                    Text(
                      advertisement.description ?? '',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),

                  ]),
                ),


              ]),
            ),
          ),

        ]),
      ),
    );
  }
}

class HighlightVideoWidget extends StatefulWidget {
  final AdvertisementModel advertisement;
  const HighlightVideoWidget({super.key, required this.advertisement});

  @override
  State<HighlightVideoWidget> createState() => _HighlightVideoWidgetState();
}

class _HighlightVideoWidgetState extends State<HighlightVideoWidget> {

  late VideoPlayerController videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();

    videoPlayerController.addListener(() {
      if(videoPlayerController.value.duration == videoPlayerController.value.position){
        if(GetPlatform.isWeb){
          Future.delayed(const Duration(seconds: 4), () {
            Get.find<AdvertisementController>().updateAutoPlayStatus(status: true, shouldUpdate: true);
          });
        }else{
          Get.find<AdvertisementController>().updateAutoPlayStatus(status: true, shouldUpdate: true);
        }
      }
    });
  }

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
      widget.advertisement.videoAttachmentFullUrl ?? "",
    ));

    await Future.wait([
      videoPlayerController.initialize(),
    ]);

    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      aspectRatio: videoPlayerController.value.aspectRatio,
    );
    _chewieController?.setVolume(0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.07), width: 2),
        ),
        child: Column(children: [

          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
              child: Stack(
                children: [
                  _chewieController != null &&  _chewieController!.videoPlayerController.value.isInitialized ? Stack(
                    children: [
                      Chewie(controller: _chewieController!),
                    ],
                  ) : const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  widget.advertisement.title ?? '',
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  Expanded(
                    child: Text(
                      widget.advertisement.description ?? '',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  InkWell(
                    onTap: (){
                      Get.toNamed(RouteHelper.getRestaurantRoute(widget.advertisement.restaurantId),
                        arguments: RestaurantScreen(restaurant: Restaurant(id: widget.advertisement.restaurantId)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: Icon(Icons.arrow_forward, color: Theme.of(context).cardColor, size: 20),
                    ),
                  ),

                ]),

              ]),
            ),
          ),

        ]),
      );
    });
  }
}

class AdvertisementIndicator extends StatelessWidget {
  const AdvertisementIndicator({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AdvertisementController>(builder: (advertisementController) {
      return advertisementController.advertisementList != null && advertisementController.advertisementList!.length > 2 ?
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(height: 7, width: 7,
          decoration:  BoxDecoration(color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: advertisementController.advertisementList!.map((advertisement) {
            int index = advertisementController.advertisementList!.indexOf(advertisement);
            return index == advertisementController.currentIndex ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),
              margin: const EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(
                  color:  Theme.of(context).primaryColor ,
                  borderRadius: BorderRadius.circular(50)),
              child:  Text("${index+1}/ ${advertisementController.advertisementList!.length}",
                style: const TextStyle(color: Colors.white,fontSize: 12),),
            ):const SizedBox();
          }).toList(),
        ),
        Container(
          height: 7, width: 7,
          decoration:  BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ]): advertisementController.advertisementList != null && advertisementController.advertisementList!.length == 2 ?
      Align(
        alignment: Alignment.center,
        child: AnimatedSmoothIndicator(
          activeIndex: advertisementController.currentIndex,
          count: advertisementController.advertisementList!.length,
          effect: ExpandingDotsEffect(
            dotHeight: 7,
            dotWidth: 7,
            spacing: 5,
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotColor: Theme.of(context).hintColor.withValues(alpha: 0.6),
          ),
        ),
      ): const SizedBox();
    });
  }
}
