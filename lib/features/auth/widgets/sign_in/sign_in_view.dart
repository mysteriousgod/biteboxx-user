import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/auth/widgets/sign_in/otp_login_widget.dart';
import 'package:stackfood_multivendor/features/favourite/controllers/favourite_controller.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
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
  final FocusNode _otpPhoneFocus = FocusNode();
  final TextEditingController _otpPhoneController = TextEditingController();
  String? _countryDialCode;
  GlobalKey<FormState>? _formKeyLogin;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    AuthController authController = Get.find<AuthController>();

    _countryDialCode = authController.getUserCountryCode().isNotEmpty
        ? authController.getUserCountryCode()
        : Get.find<SplashController>().configModel?.country != null
            ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode
            : '+880';
    _otpPhoneController.text = authController.getUserOtpPhoneNumber();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.initCountryCode(countryCode: _countryDialCode != "" ? _countryDialCode : null);
    });

    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_otpPhoneFocus);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Form(
        key: _formKeyLogin,
        child: OtpLoginWidget(
          phoneController: _otpPhoneController,
          phoneFocus: _otpPhoneFocus,
          countryDialCode: _countryDialCode,
          onCountryChanged: (CountryCode countryCode) => _countryDialCode = countryCode.dialCode,
          onClickLoginButton: () {
            _otpLogin(Get.find<AuthController>(), _countryDialCode!, CentralizeLoginType.otp);
          },
        ),
      );
    });
  }

  void _otpLogin(AuthController authController, String countryDialCode, CentralizeLoginType loginType) async {
    debugPrint('_otpLogin triggered');
    String phone = _otpPhoneController.text.trim();
    String numberWithCountryCode = countryDialCode + phone;
    
    // Normalize phone number for comparison
    String normalizedNumber = numberWithCountryCode.replaceAll(' ', '');
    debugPrint('Validating phone number: $numberWithCountryCode');
    
    bool isTestNumber = (normalizedNumber == '+911234567890');
    PhoneValid phoneValid;
    
    if (isTestNumber) {
       debugPrint('Bypassing validation for Test Number');
       phoneValid = PhoneValid(isValid: true, countryCode: countryDialCode, phone: normalizedNumber);
    } else {
       phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    }
    
    // Update the phone number to the one returned by validator (or the normalized test number)
    if (phoneValid.isValid) {
      numberWithCountryCode = phoneValid.phone;
    }

    try {
      // Validate form first
      if (!_formKeyLogin!.currentState!.validate()) {
          debugPrint('Form validation failed');
          return;
      }
      
      if (!phoneValid.isValid) {
        debugPrint('Invalid phone number validation for: $numberWithCountryCode');
        showCustomSnackBar('invalid_phone_number'.tr);
        return;
      }
      
      debugPrint('Calling authController.otpLogin...');
      try {
        ResponseModel response = await authController.otpLogin(
          phone: numberWithCountryCode,
          otp: '',
          loginType: loginType.name,
          verified: '',
          alreadyInApp: widget.backFromThis,
        );
        
        debugPrint('authController.otpLogin returned: ${response.message}');
        if (response.isSuccess) {
          debugPrint('OTP Login Success: ${response.message}');
          _processOtpSuccessSetup(response, authController, phone, countryDialCode);
        } else {
          debugPrint('OTP Login Failed: ${response.message}');
          showCustomSnackBar(response.message);
        }
      } catch (e) {
        debugPrint('Error in otpLogin: $e');
        showCustomSnackBar('Login failed: $e');
      }

    } catch (e) {
      debugPrint('Exception in _otpLogin: $e');
    }
  }

  void _processOtpSuccessSetup(ResponseModel response, AuthController authController, String phone, String countryDialCode) async {
    if (authController.isActiveRememberMeForOtp) {
      authController.saveUserNumberAndPassword(number: '', password: '', countryCode: countryDialCode, otpPoneNumber: phone);
    } else {
      authController.clearUserNumberAndPassword();
    }
    if (GetPlatform.isWeb && response.authResponseModel == null) {
      await Get.find<FavouriteController>().getFavouriteList();
    }
    if (response.authResponseModel != null && !response.authResponseModel!.isPhoneVerified!) {
      // Always use Firebase Phone Auth for OTP verification
      Get.find<AuthController>().firebaseVerifyPhoneNumber(countryDialCode + phone, '', CentralizeLoginType.otp.name, fromSignUp: true);
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