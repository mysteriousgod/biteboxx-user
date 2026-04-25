import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/signup_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/auth_service_interface.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/update_user_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/verification/screens/verification_screen.dart';
import 'package:stackfood_multivendor/helper/recaptcha_helper.dart';
import 'package:stackfood_multivendor/helper/responsive_helper.dart';
import 'package:stackfood_multivendor/helper/route_helper.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authServiceInterface;
  AuthController({required this.authServiceInterface}) {
    _notification = authServiceInterface.isNotificationActive();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _notificationLoading = false;
  bool get notificationLoading => _notificationLoading;

  bool _guestLoading = false;
  bool get guestLoading => _guestLoading;

  bool _acceptTerms = true;
  bool get acceptTerms => _acceptTerms;

  bool _isActiveRememberMe = false;
  bool get isActiveRememberMe => _isActiveRememberMe;

  bool _isActiveRememberMeForOtp = false;
  bool get isActiveRememberMeForOtp => _isActiveRememberMeForOtp;

  bool _notification = true;
  bool get notification => _notification;

  bool _isNumberLogin = false;
  bool get isNumberLogin => _isNumberLogin;

  var countryDialCode = "+880";

  bool _isOtpViewEnable = false;
  bool get isOtpViewEnable => _isOtpViewEnable;

  Future<ResponseModel> login(
          {required String emailOrPhone,
          required String password,
          required String loginType,
          required String fieldType,
          bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.login(
        emailOrPhone: emailOrPhone,
        password: password,
        loginType: loginType,
        fieldType: fieldType,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> otpLogin(
          {required String phone,
          required String loginType,
          required String otp,
          required String verified,
          bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.otpLogin(
        phone: phone,
        otp: otp,
        loginType: loginType,
        verified: verified,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void resetOtpView({bool isUpdate = true}) {
    _isOtpViewEnable = false;
    if (isUpdate) {
      update();
    }
  }

  Future<ResponseModel> updatePersonalInfo(
          {required String name,
          required String? phone,
          required String loginType,
          required String? email,
          required String? referCode,
          bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.updatePersonalInfo(
        name: name,
        phone: phone,
        email: email,
        loginType: loginType,
        referCode: referCode,
        alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void _getUserAndCartData(ResponseModel responseModel) {
    if (responseModel.isSuccess &&
        responseModel.authResponseModel != null &&
        responseModel.authResponseModel!.isPhoneVerified! &&
        responseModel.authResponseModel!.isEmailVerified! &&
        responseModel.authResponseModel!.isPersonalInfo! &&
        responseModel.authResponseModel!.isExistUser == null) {
      Get.find<ProfileController>().getUserInfo();
      Get.find<CartController>().getCartDataOnline();
    }
  }

  Future<ResponseModel> registration(SignUpBodyModel signUpModel) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.registration(signUpModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void toggleIsNumberLogin({bool? value, bool willUpdate = true}) {
    if (value == null) {
      _isNumberLogin = !_isNumberLogin;
    } else {
      _isNumberLogin = value;
    }
    initCountryCode();
    if (willUpdate) {
      update();
    }
  }

  void enableOtpView({bool enable = false}) {
    _isOtpViewEnable = enable;
    update();
  }

  void initCountryCode({String? countryCode}) {
    countryDialCode = countryCode ??
        CountryCode.fromCountryCode(
                Get.find<SplashController>().configModel!.country ?? "BD")
            .dialCode ??
        "+880";
  }

  void saveUserNumberAndPassword(
      {required String number,
      required String password,
      required String countryCode,
      required String otpPoneNumber}) {
    authServiceInterface.saveUserNumberAndPassword(
        number: number,
        password: password,
        countryCode: countryCode,
        otpPoneNumber: otpPoneNumber);
  }

  Future<bool> clearUserNumberAndPassword() async {
    return authServiceInterface.clearUserNumberAndPassword();
  }

  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  String getUserCountryCode() {
    return authServiceInterface.getUserCountryCode();
  }

  String getUserNumber() {
    return authServiceInterface.getUserNumber();
  }

  String getUserPassword() {
    return authServiceInterface.getUserPassword();
  }

  String getUserOtpPhoneNumber() {
    return authServiceInterface.getUserOtpPhoneNumber();
  }

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  void toggleRememberMeForOtp() {
    _isActiveRememberMeForOtp = !_isActiveRememberMeForOtp;
    update();
  }

  Future<ResponseModel> guestLogin() async {
    _guestLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.guestLogin();
    _guestLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> loginWithSocialMedia(
      SocialLogInBodyModel socialLogInBody) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.loginWithSocialMedia(
        socialLogInBody,
        isCustomerVerificationOn:
            Get.find<SplashController>().configModel!.customerVerification!);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  String getGuestId() {
    return authServiceInterface.getGuestId();
  }

  bool isGuestLoggedIn() {
    return authServiceInterface.isGuestLoggedIn() && !authServiceInterface.isLoggedIn();
  }

  Future<void> socialLogout() async {
    await authServiceInterface.socialLogout();
  }

  Future<bool> clearSharedData({bool removeToken = true}) async {
    return await authServiceInterface.clearSharedData(removeToken: removeToken);
  }

  Future<bool> setNotificationActive(bool isActive) async {
    _notificationLoading = true;
    update();
    _notification = isActive;
    await authServiceInterface.setNotificationActive(isActive);
    _notificationLoading = false;
    update();
    return _notification;
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<void> saveGuestNumber(String number) async {
    authServiceInterface.saveGuestNumber(number);
  }

  String getGuestNumber() {
    return authServiceInterface.getGuestNumber();
  }

  int? _forceResendingToken;

  /// Verifies phone number using Firebase Auth with proper reCAPTCHA handling.
  ///
  /// Firebase Auth handles reCAPTCHA automatically on all platforms:
  /// - **Web**: Shows invisible reCAPTCHA v2 challenge automatically
  /// - **iOS**: Uses invisible reCAPTCHA or App Attest internally
  /// - **Android**: Uses visible/invisible reCAPTCHA internally
  Future<void> firebaseVerifyPhoneNumber(
    String phoneNumber,
    String? token,
    String loginType, {
    bool fromSignUp = true,
    bool canRoute = true,
    UpdateUserModel? updateUserModel,
  }) async {
    _isLoading = true;
    update();

    debugPrint('===== Firebase Phone Auth =====');
    debugPrint('Phone: $phoneNumber');
    debugPrint('LoginType: $loginType');
    debugPrint('FromSignUp: $fromSignUp');
    debugPrint('IsWeb: $kIsWeb');

    // Log reCAPTCHA status for debugging
    RecaptchaHelper.logStatus();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _forceResendingToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('===== Auto-verification completed =====');
          debugPrint('Credential received, signing in...');

          try {
            final userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            debugPrint(
                '===== Auto-signed in: ${userCredential.user?.uid} =====');

            _isLoading = false;
            update();

            // Navigate to home or next screen after auto-verification
            // This handles the case where Firebase auto-verifies
            // (e.g., iOS simulator with test numbers)
          } catch (e) {
            debugPrint('===== Auto-sign-in failed: $e =====');
            _isLoading = false;
            update();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          update();

          debugPrint('===== Firebase Verification Failed =====');
          debugPrint('Error code: ${e.code}');
          debugPrint('Error message: ${e.message}');

          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'please_submit_a_valid_phone_number'.tr;
              break;
            case 'too-many-requests':
              errorMessage = 'Too many OTP requests. Please try again later.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            case 'app-not-authorized':
              if (kIsWeb) {
                errorMessage =
                    'App not authorized for Firebase Phone Auth. Add your domain to Authorized domains in Firebase Console.';
              } else {
                errorMessage =
                    'App not authorized for Firebase Phone Auth. Check SHA-1 fingerprint in Firebase Console.';
              }
              break;
            case 'captcha-check-failed':
              errorMessage = 'reCAPTCHA verification failed. Please try again.';
              break;
            case 'missing-client-identifier':
              errorMessage =
                  'Missing client identifier. Please check Firebase configuration.';
              break;
            case 'unauthorized-domain':
              errorMessage =
                  'This domain is not authorized for Firebase Auth. Add it in Firebase Console > Authentication > Settings > Authorized domains.';
              break;
            case 'web-reCAPTCHA-site-key-mismatch':
              errorMessage =
                  'reCAPTCHA site key mismatch. Please check Firebase Console settings.';
              break;
            default:
              errorMessage = e.message?.replaceAll('_', ' ') ??
                  'Phone verification failed. Please try again.';
          }
          showCustomSnackBar(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('===== OTP Code Sent Successfully =====');
          debugPrint('Verification ID: $verificationId');
          debugPrint('Resend Token: $resendToken');

          _isLoading = false;
          _forceResendingToken = resendToken;
          update();

          if (updateUserModel != null) {
            updateUserModel.sessionInfo = verificationId;
          }

          if (canRoute) {
            if (ResponsiveHelper.isDesktop(Get.context)) {
              Get.back();
              Get.dialog(VerificationScreen(
                number: phoneNumber,
                email: null,
                token: token,
                fromSignUp: fromSignUp,
                fromForgetPassword: !fromSignUp,
                loginType: loginType,
                password: '',
                firebaseSession: verificationId,
                userModel: updateUserModel,
              ));
            } else {
              Get.toNamed(
                RouteHelper.getVerificationRoute(
                  phoneNumber,
                  '',
                  token,
                  fromSignUp ? RouteHelper.signUp : RouteHelper.forgotPassword,
                  '',
                  loginType,
                  session: verificationId,
                  updateUserModel: updateUserModel,
                ),
              );
            }
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
              '===== Auto retrieval timeout for: $verificationId =====');
        },
      );
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      update();
      debugPrint('===== Firebase Auth Exception =====');
      debugPrint('Error code: ${e.code}');
      debugPrint('Error message: ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'invalid-phone-number':
          errorMessage = 'please_submit_a_valid_phone_number'.tr;
          break;
        case 'too-many-requests':
          errorMessage = 'Too many OTP requests. Please try again later.';
          break;
        case 'quota-exceeded':
          errorMessage = 'SMS quota exceeded. Please try again later.';
          break;
        case 'captcha-check-failed':
          errorMessage = 'reCAPTCHA verification failed. Please try again.';
          break;
        default:
          errorMessage = e.message?.replaceAll('_', ' ') ??
              'Phone verification failed. Please try again.';
      }
      showCustomSnackBar(errorMessage);
    } catch (e) {
      _isLoading = false;
      update();
      debugPrint('===== Firebase Phone Auth Exception =====');
      debugPrint('Error: $e');
      showCustomSnackBar('Failed to send OTP: ${e.toString()}');
    }
  }
}