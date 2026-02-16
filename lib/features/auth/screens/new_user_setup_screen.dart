import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_button_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/images.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class NewUserSetupScreen extends StatefulWidget {
  final String name;
  final String loginType;
  final String? phone;
  final String? email;
  const NewUserSetupScreen({super.key, required this.name, required this.loginType, required this.phone, required this.email});

  @override
  State<NewUserSetupScreen> createState() => _NewUserSetupScreenState();
}

class _NewUserSetupScreenState extends State<NewUserSetupScreen> {
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _referCodeFocus = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  GlobalKey<FormState>? _formKeyInfo;

  @override
  void initState() {
    super.initState();
    _formKeyInfo = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context) ? Colors.transparent : Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? null : AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: SafeArea(child: Align(
        alignment: ResponsiveHelper.isDesktop(context) ? Alignment.center : Alignment.topCenter,
        child: Container(
          width: context.width > 700 ? 500 : context.width,
          padding: context.width > 700 ? const EdgeInsets.all(50) : const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
          margin: context.width > 700 ? const EdgeInsets.all(50) : EdgeInsets.zero,
          decoration: context.width > 700 ? BoxDecoration(
            color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            boxShadow: ResponsiveHelper.isDesktop(context) ? null : [BoxShadow(color: Colors.grey[Get.isDarkMode ? 700 : 300]!, blurRadius: 5, spreadRadius: 1)],
          ) : null,
          child: SingleChildScrollView(
            child: Form(
              key: _formKeyInfo,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                ResponsiveHelper.isDesktop(context) ? Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.clear),
                  ),
                ) : const SizedBox(),

                CustomImageWidget(
                  image: Get.find<SplashController>().configModel?.logoFullUrl ?? '',
                  height: 50, width: 200, fit: BoxFit.contain,
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text('just_one_step_away'.tr, style: robotoMedium.copyWith(color: Theme.of(context).disabledColor), textAlign: TextAlign.center),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Text(
                  'please_enter_your_name_to_complete_setup'.tr.isEmpty
                      ? 'Please enter your name to complete your account setup'
                      : 'please_enter_your_name_to_complete_setup'.tr,
                  style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.paddingSizeOverLarge),

                CustomTextFieldWidget(
                  hintText: 'ex_jhon'.tr,
                  labelText: 'user_name'.tr,
                  showLabelText: true,
                  required: true,
                  controller: _nameController,
                  focusNode: _nameFocus,
                  nextFocus: _referCodeFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  prefixIcon: CupertinoIcons.person_alt_circle_fill,
                  levelTextSize: Dimensions.fontSizeDefault,
                  validator: (value) => ValidateCheck.validateEmptyText(value, "please_enter_your_name".tr),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                // Phone number display — read-only, already collected during OTP
                if (widget.phone != null && widget.phone!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Icon(Icons.phone_android, color: Theme.of(context).primaryColor, size: 20),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Text(
                        widget.phone!,
                        style: robotoMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color),
                      ),
                      const Spacer(),
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                    ]),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                ],

                (Get.find<SplashController>().configModel!.refEarningStatus == 1) ? CustomTextFieldWidget(
                  hintText: 'refer_code'.tr,
                  labelText: 'refer_code'.tr,
                  showLabelText: true,
                  controller: _referCodeController,
                  focusNode: _referCodeFocus,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.text,
                  capitalization: TextCapitalization.words,
                  prefixImage: Images.referCode,
                  divider: false,
                  prefixSize: 14,
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                GetBuilder<AuthController>(builder: (authController) {
                  return CustomButtonWidget(
                    height: ResponsiveHelper.isDesktop(context) ? 50 : null,
                    width: ResponsiveHelper.isDesktop(context) ? 250 : null,
                    radius: ResponsiveHelper.isDesktop(context) ? Dimensions.radiusSmall : Dimensions.radiusDefault,
                    isBold: !ResponsiveHelper.isDesktop(context),
                    fontSize: ResponsiveHelper.isDesktop(context) ? Dimensions.fontSizeSmall : null,
                    buttonText: 'done'.tr,
                    isLoading: authController.isLoading,
                    onPressed: () async {
                      String name = _nameController.text.trim();
                      String referCode = _referCodeController.text.trim();

                      if (referCode.isNotEmpty && referCode.length != 10) {
                        showCustomSnackBar('invalid_refer_code'.tr);
                      } else if (_formKeyInfo!.currentState!.validate()) {
                        authController.updatePersonalInfo(
                          name: name.isNotEmpty ? name : widget.name,
                          phone: widget.phone,
                          loginType: widget.loginType,
                          email: widget.email,
                          referCode: _referCodeController.text.trim(),
                        ).then((response) {
                          if (response.isSuccess) {
                            Get.offAllNamed(RouteHelper.getAccessLocationRoute('sign-in'));
                          } else {
                            showCustomSnackBar(response.message);
                          }
                        });
                      }
                    },
                  );
                }),

              ]),
            ),
          ),
        ),
      )),
    );
  }
}
