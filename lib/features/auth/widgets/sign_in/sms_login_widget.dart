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
import 'package:flutter/cupertino.dart';

class SmsLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final FocusNode phoneFocus;
  final FocusNode nameFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  const SmsLoginWidget({
    super.key,
    required this.phoneController,
    required this.nameController,
    required this.phoneFocus,
    required this.nameFocus,
    required this.onCountryChanged,
    required this.countryDialCode,
    required this.onClickLoginButton,
  });

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
              'enter_your_name_and_phone_to_continue'.tr,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomTextFieldWidget(
            hintText: 'ex_jhon'.tr,
            labelText: 'your_name'.tr,
            showLabelText: true,
            required: true,
            controller: nameController,
            focusNode: nameFocus,
            nextFocus: phoneFocus,
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
            prefixIcon: CupertinoIcons.person_alt_circle_fill,
            validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_your_name".tr),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

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

          TramsConditionsCheckBoxWidget(authController: authController, fromDialog: true),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          CustomButtonWidget(
            buttonText: 'continue'.tr,
            radius: Dimensions.radiusDefault,
            isBold: isDesktop ? false : true,
            isLoading: authController.isLoading,
            onPressed: authController.acceptTerms ? onClickLoginButton : null,
            fontSize: isDesktop ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // No social login or other auth methods - SMS only
          const SizedBox(height: 50),

        ]),
      );
    });
  }
}
