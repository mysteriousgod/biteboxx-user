import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AccountDeletionBottomSheet extends StatefulWidget {
  final ProfileController profileController;
  final bool isRunningOrderAvailable;
  const AccountDeletionBottomSheet({super.key, required this.profileController, this.isRunningOrderAvailable = false});

  @override
  State<AccountDeletionBottomSheet> createState() => _AccountDeletionBottomSheetState();
}

class _AccountDeletionBottomSheetState extends State<AccountDeletionBottomSheet> {
  String _otpCode = '';
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    widget.profileController.resetDeleteAccountState();
  }

  void _startResendTimer() {
    _timer?.cancel();
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    String? userPhone = widget.profileController.userInfoModel?.phone;

    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 500 : context.width,
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      child: GetBuilder<ProfileController>(
        builder: (pController) {
          return SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
                height: 5, width: 35,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge),

              Stack(clipBehavior: Clip.none, children: [
                ClipOval(child: CustomImageWidget(
                  placeholder: Images.guestIconLight,
                  imageColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                  image: '${(widget.profileController.userInfoModel != null && isLoggedIn) ? widget.profileController.userInfoModel!.imageFullUrl : ''}',
                  height: 70, width: 70, fit: BoxFit.cover,
                )),

                Positioned(
                  right: -5, top: 0,
                  child: Icon(
                    widget.isRunningOrderAvailable ? Icons.warning_rounded : CupertinoIcons.clear_circled_solid,
                    color: Theme.of(context).colorScheme.error,
                    size: 25,
                  ),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              Text(
                widget.isRunningOrderAvailable
                    ? 'sorry_you_cannot_delete_your_account'.tr
                    : pController.isDeleteOtpSent
                        ? 'enter_verification_code'.tr
                        : 'delete_your_account'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              if (widget.isRunningOrderAvailable) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'please_complete_your_ongoing_and_accepted_orders'.tr,
                    style: robotoRegular, textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
                CustomButtonWidget(
                  buttonText: 'view_orders'.tr,
                  height: 40,
                  color: Theme.of(context).primaryColor,
                  fontSize: Dimensions.fontSizeDefault,
                  onPressed: () {
                    Get.back();
                    Get.toNamed(RouteHelper.getOrderRoute());
                  },
                ),
              ] else if (!pController.isDeleteOtpSent) ...[
                // Stage 1: Grace period explanation & request OTP
                Container(
                  margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.error, size: 20),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text('14-Day Grace Period', style: robotoBold.copyWith(color: Theme.of(context).colorScheme.error)),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      'account_deletion_grace_period_notice'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ]),
                ),

                if (userPhone != null && userPhone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: Text(
                      'SMS OTP will be sent to $userPhone',
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                      textAlign: TextAlign.center,
                    ),
                  ),

                pController.isLoading ? const Center(child: CircularProgressIndicator()) : Row(children: [
                  Expanded(child: CustomButtonWidget(
                    buttonText: 'cancel'.tr,
                    height: 42,
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                    fontSize: Dimensions.fontSizeDefault,
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () => Get.back(),
                  )),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(child: CustomButtonWidget(
                    buttonText: 'send_verification_code'.tr,
                    height: 42,
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeDefault,
                    isLoading: pController.isLoading,
                    onPressed: () async {
                      bool success = await pController.sendDeleteAccountOtp();
                      if (success) {
                        _startResendTimer();
                      }
                    },
                  )),
                ]),
              ] else ...[
                // Stage 2: OTP verification input & confirmation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    userPhone != null
                        ? 'We sent a 6-digit verification code to $userPhone'
                        : 'Enter the 6-digit code sent to your phone',
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    textAlign: TextAlign.center,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: PinCodeTextField(
                    length: 6,
                    appContext: context,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      fieldHeight: 50,
                      fieldWidth: 42,
                      borderWidth: 1,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      selectedColor: Theme.of(context).primaryColor,
                      selectedFillColor: Theme.of(context).cardColor,
                      inactiveFillColor: Theme.of(context).cardColor,
                      inactiveColor: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                      activeColor: Theme.of(context).primaryColor,
                      activeFillColor: Theme.of(context).cardColor,
                    ),
                    animationDuration: const Duration(milliseconds: 250),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onChanged: (value) {
                      setState(() {
                        _otpCode = value;
                      });
                    },
                  ),
                ),

                // Resend Timer Row
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    _seconds > 0
                        ? '${'resend_code_in'.tr} ${_seconds}s'
                        : 'did_not_receive_the_code'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(width: 5),
                  if (_seconds == 0)
                    InkWell(
                      onTap: pController.isLoading ? null : () async {
                        bool success = await pController.sendDeleteAccountOtp();
                        if (success) {
                          _startResendTimer();
                        }
                      },
                      child: Text(
                        'resend_code'.tr,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
                      ),
                    ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                pController.isLoading ? const Center(child: CircularProgressIndicator()) : Row(children: [
                  Expanded(child: CustomButtonWidget(
                    buttonText: 'back'.tr,
                    height: 42,
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.4),
                    fontSize: Dimensions.fontSizeDefault,
                    textColor: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () {
                      pController.resetDeleteAccountState();
                    },
                  )),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(child: CustomButtonWidget(
                    buttonText: 'confirm_deletion'.tr,
                    height: 42,
                    color: Theme.of(context).colorScheme.error,
                    fontSize: Dimensions.fontSizeDefault,
                    isLoading: pController.isLoading,
                    onPressed: _otpCode.length < 6 ? null : () {
                      pController.removeUserWithOtp(_otpCode);
                    },
                  )),
                ]),
              ],

              const SizedBox(height: Dimensions.paddingSizeSmall),
            ]),
          );
        },
      ),
    );
  }
}
