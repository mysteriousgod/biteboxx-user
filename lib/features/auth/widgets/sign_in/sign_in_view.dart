import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/common/widgets/validate_check.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/sms_login_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';
import 'package:stackfood_multivendor/features/verification/screens/verification_screen.dart';
import 'package:stackfood_multivendor/helper/custom_validator.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class SignInView extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromResetPassword;
  final Function(bool val)? isOtpViewEnable;
  const SignInView({super.key, required this.exitFromApp, required this.backFromThis, this.fromResetPassword = false, this.isOtpViewEnable});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeyLogin;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    AuthController authController = Get.find<AuthController>();

    _countryDialCode = authController.getUserCountryCode().isNotEmpty ? authController.getUserCountryCode()
        : CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode;
    _phoneController.text = authController.getUserOtpPhoneNumber();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.initCountryCode(countryCode: _countryDialCode != "" ? _countryDialCode : null);
    });

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_nameFocus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Form(
        key: _formKeyLogin,
        child: SmsLoginWidget(
          phoneController: _phoneController,
          nameController: _nameController,
          phoneFocus: _phoneFocus,
          nameFocus: _nameFocus,
          countryDialCode: _countryDialCode,
          onCountryChanged: (CountryCode countryCode) => _countryDialCode = countryCode.dialCode,
          onClickLoginButton: () {
            _otpLogin(Get.find<AuthController>(), _countryDialCode!);
          },
        ),
      );
    });
  }

  void _otpLogin(AuthController authController, String countryDialCode) async {
    String phone = _phoneController.text.trim();
    String name = _nameController.text.trim();
    String numberWithCountryCode = countryDialCode + phone;
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeyLogin!.currentState!.validate()) {
      if (!phoneValid.isValid) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else if (name.isEmpty) {
        showCustomSnackBar('please_enter_your_name'.tr);
      } else {
        // Save the name for later use during new user setup
        authController.setSmsLoginName(name);
        authController.otpLogin(phone: numberWithCountryCode, otp: '', loginType: CentralizeLoginType.otp.name, verified: '', alreadyInApp: widget.backFromThis).then((response) {
          if (response.isSuccess) {
            _processOtpSuccessSetup(response, authController, phone, countryDialCode);
          } else {
            showCustomSnackBar(response.message);
          }
        });
      }
    }
  }

  void _processOtpSuccessSetup(ResponseModel response, AuthController authController, String phone, String countryDialCode) async {
    authController.saveUserNumberAndPassword(number: '', password: '', countryCode: countryDialCode, otpPoneNumber: phone);

    if (GetPlatform.isWeb && response.authResponseModel == null) {
      await Get.find<FavouriteController>().getFavouriteList();
    }
    if (response.authResponseModel != null && !response.authResponseModel!.isPhoneVerified!) {
      if (Get.find<SplashController>().configModel!.firebaseOtpVerification!) {
        Get.find<AuthController>().firebaseVerifyPhoneNumber(countryDialCode + phone, '', CentralizeLoginType.otp.name, fromSignUp: true);
      } else {
        if (ResponsiveHelper.isDesktop(Get.context)) {
          Get.back();
          Get.dialog(VerificationScreen(
            number: countryDialCode + phone, email: null, token: '', fromSignUp: true,
            fromForgetPassword: false, loginType: CentralizeLoginType.otp.name, password: '',
          ));
        } else {
          Get.toNamed(RouteHelper.getVerificationRoute(
            countryDialCode + phone, null, '', RouteHelper.signUp, null, CentralizeLoginType.otp.name,
          ));
        }
      }
    } else {
      if (widget.backFromThis) {
        if (ResponsiveHelper.isDesktop(Get.context)) {
          Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: false));
        } else {
          Get.back();
        }
      } else {
        Get.find<SplashController>().navigateToLocationScreen('sign-in', offNamed: true);
      }
    }
  }
}
