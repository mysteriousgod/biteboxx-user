import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/widgets/trams_conditions_check_box_widget.dart';
import 'package:stackfood_multivendor/features/language/controllers/localization_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class OtpLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final bool socialEnable;
  final Function()? onMainViewClick;
  const OtpLoginWidget({super.key, required this.phoneController, required this.phoneFocus, required this.onCountryChanged, required this.countryDialCode, required this.onClickLoginButton, this.socialEnable = false, this.onMainViewClick});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text('login'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'enter_your_mobile_number_to_continue'.tr.isEmpty
                  ? 'Enter your mobile number to sign in or create an account'
                  : 'enter_your_mobile_number_to_continue'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextFieldWidget(
            hintText: 'xxx-xxx-xxxxx'.tr,
            controller: phoneController,
            focusNode: phoneFocus,
            inputAction: TextInputAction.done,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: onCountryChanged,
            countryDialCode: CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).code ?? Get.find<LocalizationController>().locale.countryCode,
            labelText: 'phone'.tr,
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_phone_number".tr),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => authController.toggleRememberMeForOtp(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24, width: 24,
                    child: Checkbox(
                      side: BorderSide(color: Theme.of(context).hintColor),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: Theme.of(context).primaryColor,
                      value: authController.isActiveRememberMeForOtp,
                      onChanged: (bool? isChecked) => authController.toggleRememberMeForOtp(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text('remember_me'.tr, style: robotoRegular),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          TramsConditionsCheckBoxWidget(authController: authController, fromDialog: true),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomButtonWidget(
            buttonText: 'Continue',
            radius: Dimensions.radiusDefault,
            isBold: isDesktop ? false : true,
            isLoading: authController.isLoading,
            onPressed: authController.acceptTerms ? onClickLoginButton : null,
            fontSize: isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // No social login, no sign-up link — phone OTP only
          const SizedBox(height: 50),

        ]),
      );
    });
  }
}
