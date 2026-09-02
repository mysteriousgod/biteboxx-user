import 'package:stackfood_multivendor/common/widgets/custom_loader_widget.dart';
import 'package:stackfood_multivendor/common/widgets/not_logged_in_screen.dart';
import 'package:stackfood_multivendor/features/address/controllers/address_controller.dart';
import 'package:stackfood_multivendor/features/address/domain/models/address_model.dart';
import 'package:stackfood_multivendor/features/address/widgets/address_confirmation_dialogue_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/location/controllers/location_controller.dart';
import 'package:stackfood_multivendor/helper/address_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';
import 'package:stackfood_multivendor/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/footer_view_widget.dart';
import 'package:stackfood_multivendor/common/widgets/menu_drawer_widget.dart';
import 'package:stackfood_multivendor/common/widgets/no_data_screen_widget.dart';
import 'package:stackfood_multivendor/common/widgets/web_page_title_widget.dart';
import 'package:stackfood_multivendor/features/address/widgets/address_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall(){
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
  }

  bool _isAddressActive(AddressModel address, AddressModel? active) {
    if (active == null) return false;
    if (address.id != null && active.id != null) {
      return address.id == active.id;
    }
    return address.latitude == active.latitude && address.longitude == active.longitude;
  }

  Future<void> _setActiveAddress(AddressModel address) async {
    Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
    bool success = await Get.find<LocationController>().setActiveAddress(address);
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    if (success) {
      showCustomSnackBar('Active address updated successfully', isError: false);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return GetBuilder<AddressController>(builder: (addressController) {
      return Scaffold (

        appBar: CustomAppBarWidget(title: 'my_address'.tr),

        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,

        floatingActionButton:  ResponsiveHelper.isDesktop(context) || !isLoggedIn ? null : (addressController.addressList?.isEmpty ?? true) ? null : FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
          child: Icon(Icons.add, color: Theme.of(context).cardColor),
        ),
        floatingActionButtonLocation: ResponsiveHelper.isDesktop(context) ? FloatingActionButtonLocation.centerFloat : null,

        body: GetBuilder<AddressController>(builder: (addressController) {
          return isLoggedIn ? RefreshIndicator(
            onRefresh: () async {
              await addressController.getAddressList();
            },
            child: Container(
              height: context.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: addressController.addressList != null ? AssetImage(addressController.addressList!.isNotEmpty ? Images.city : Images.cityWhite)
                      : const AssetImage(Images.city),
                  alignment: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(children: [

                  WebScreenTitleWidget(title: 'address'.tr),

                  Center(child: FooterViewWidget(
                    child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: Column(children: [

                        ResponsiveHelper.isDesktop(context) ? const SizedBox(height: Dimensions.paddingSizeLarge) : const SizedBox(),

                        addressController.addressList != null ? addressController.addressList!.isNotEmpty ? Padding(
                          padding: ResponsiveHelper.isMobile(context) ? const EdgeInsets.all(Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisSpacing: Dimensions.paddingSizeLarge,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              mainAxisExtent: ResponsiveHelper.isDesktop(context) ? 90 : 85,
                              crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : ResponsiveHelper.isTab(context) ? 2 : 3,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(ResponsiveHelper.isTab(context) ? Dimensions.paddingSizeSmall : 0),
                            shrinkWrap: true,
                            itemCount: ResponsiveHelper.isDesktop(context) ? (addressController.addressList!.length + 1)  : addressController.addressList!.length,
                            itemBuilder: (context, index) {
                              if (ResponsiveHelper.isDesktop(context) && (index == addressController.addressList!.length)) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                  child: InkWell(
                                    onTap: () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
                                    child: Container(
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                      decoration:  BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 1))],
                                      ),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                                        Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                                        const SizedBox(height: Dimensions.paddingSizeSmall),

                                        Text('add_new_address'.tr, style: robotoRegular.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),

                                      ]),
                                    ),
                                  ),
                                );
                              }

                              final address = addressController.addressList![index];
                              final activeAddress = AddressHelper.getAddressFromSharedPref();
                              final isSelected = _isAddressActive(address, activeAddress);

                              return AddressCardWidget(
                                address: address,
                                fromAddress: true,
                                isSelected: isSelected,
                                onTap: () {
                                  if (!isSelected) {
                                    _setActiveAddress(address);
                                  } else {
                                    showCustomSnackBar('This is already your active address', isError: false);
                                  }
                                },
                                onEditPressed: () {
                                  Get.toNamed(RouteHelper.getEditAddressRoute(address));
                                },
                                onRemovePressed: () {
                                  if(Get.isSnackbarOpen) {
                                    Get.back();
                                  }
                                  Get.dialog(AddressConfirmDialogueWidget(
                                    icon: Images.locationConfirm,
                                    title: 'are_you_sure'.tr,
                                    description: 'you_want_to_delete_this_location'.tr,
                                    onYesPressed: () {
                                      addressController.deleteAddress(address.id, index).then((response) {
                                        Get.back();
                                        if (response.isSuccess) {
                                          final currentActive = AddressHelper.getAddressFromSharedPref();
                                          if (_isAddressActive(address, currentActive)) {
                                            if (addressController.addressList != null && addressController.addressList!.isNotEmpty) {
                                              _setActiveAddress(addressController.addressList!.first);
                                            } else {
                                              AddressHelper.clearAddressFromSharedPref();
                                            }
                                          }
                                          setState(() {});
                                        }
                                        showCustomSnackBar(response.message, isError: !response.isSuccess);
                                      });
                                    },
                                  ));
                                },
                              );
                            },
                          ),
                        ) : NoDataScreen(title: 'no_address_found'.tr, isEmptyAddress: true, fromAddress: true) : Center(child: Padding(
                          padding: EdgeInsets.only(top: context.height * 0.4),
                          child: CircularProgressIndicator(),
                        )),

                      ]),
                    ),
                  )),

                ]),
              ),
            ),
          ) : NotLoggedInScreen(callBack: (value){
            _initCall();
            setState(() {});
          });
        }),
      );
    });
  }
}