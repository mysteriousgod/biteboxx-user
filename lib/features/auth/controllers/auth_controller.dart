import 'dart:developer' as developer;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stackfood_multivendor/common/models/response_model.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/cart/controllers/cart_controller.dart';
import 'package:stackfood_multivendor/features/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor/features/profile/domain/models/update_user_model.dart';
import 'package:stackfood_multivendor/features/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/signup_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/models/social_log_in_body_model.dart';
import 'package:stackfood_multivendor/features/auth/domain/services/auth_service_interface.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/features/verification/screens/verification_screen.dart';
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

  var countryDialCode= "+880";

  bool _isOtpViewEnable = false;
  bool get isOtpViewEnable => _isOtpViewEnable;

  String _smsLoginName = '';
  String get smsLoginName => _smsLoginName;

  void setSmsLoginName(String name) {
    _smsLoginName = name;
  }

  Future<ResponseModel> login({required String emailOrPhone, required String password, required String loginType, required String fieldType, bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.login(emailOrPhone: emailOrPhone, password: password, loginType: loginType, fieldType: fieldType, alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> otpLogin({required String phone, required String loginType, required String otp, required String verified, bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.otpLogin(phone: phone, otp: otp, loginType: loginType, verified: verified, alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void resetOtpView({bool isUpdate = true}) {
    _isOtpViewEnable = false;
    if(isUpdate) {
      update();
    }
  }

  Future<ResponseModel> updatePersonalInfo({required String name, required String? phone, required String loginType, required String? email, required String? referCode, bool alreadyInApp = false}) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.updatePersonalInfo(name: name, phone: phone, email: email, loginType: loginType, referCode: referCode, alreadyInApp: alreadyInApp);
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  void _getUserAndCartData(ResponseModel responseModel) {
    if(responseModel.isSuccess && responseModel.authResponseModel != null && responseModel.authResponseModel!.isPhoneVerified!
        && responseModel.authResponseModel!.isEmailVerified! && responseModel.authResponseModel!.isPersonalInfo!
        && responseModel.authResponseModel!.isExistUser == null) {
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

  void toggleIsNumberLogin({bool? value, bool willUpdate = true}){
    if(value == null){
      _isNumberLogin = !_isNumberLogin;
    }else{
      _isNumberLogin = value;
    }
    initCountryCode();
    if(willUpdate){
      update();
    }
  }

  void enableOtpView({bool enable = false}) {
    _isOtpViewEnable = enable;
    update();
  }

  void initCountryCode({String? countryCode}){
    countryDialCode = countryCode ?? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country ?? "BD").dialCode ?? "+880";
  }

  void saveUserNumberAndPassword({required String number, required String password, required String countryCode, required String otpPoneNumber}) {
    authServiceInterface.saveUserNumberAndPassword(number: number, password: password, countryCode: countryCode, otpPoneNumber: otpPoneNumber);
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

  Future<ResponseModel> loginWithSocialMedia(SocialLogInBodyModel socialLogInBody) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.loginWithSocialMedia(socialLogInBody, isCustomerVerificationOn: Get.find<SplashController>().configModel!.customerVerification!);
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

  // --- Firebase Phone Auth: rate-limit & resend token tracking ---
  int? _forceResendingToken;
  int? get forceResendingToken => _forceResendingToken;

  DateTime? _lastOtpRequestTime;
  static const int _otpCooldownSeconds = 30;

  /// Returns true if we are still within the cooldown window after the last
  /// OTP request. Shows a user-facing message and refuses to fire another
  /// request so we don't hit Firebase's rate-limiter.
  bool _isRateLimited() {
    if (_lastOtpRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastOtpRequestTime!).inSeconds;
      if (elapsed < _otpCooldownSeconds) {
        final remaining = _otpCooldownSeconds - elapsed;
        showCustomSnackBar('please_wait_before_requesting_another_code'.trParams({'seconds': '$remaining'}) );
        return true;
      }
    }
    return false;
  }

  /// Translates raw Firebase error codes into user-friendly messages.
  String _friendlyFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'please_submit_a_valid_phone_number'.tr;
      case 'too-many-requests':
        return 'too_many_attempts_please_try_again_later'.tr;
      case 'quota-exceeded':
        return 'sms_quota_exceeded_please_try_again_later'.tr;
      case 'app-not-authorized':
        return 'app_not_authorized_for_firebase_phone_auth'.tr;
      case 'captcha-check-failed':
        return 'verification_failed_please_try_again'.tr;
      case 'missing-client-identifier':
        return 'app_verification_failed_please_reinstall'.tr;
      case 'network-request-failed':
        return 'network_error_check_your_connection'.tr;
      case 'user-disabled':
        return 'this_account_has_been_disabled'.tr;
      case 'session-expired':
        return 'verification_code_expired_please_resend'.tr;
      case 'invalid-verification-code':
        return 'invalid_verification_code'.tr;
      default:
        // Fallback: clean up the raw message a little
        return e.message?.replaceAll('_', ' ') ?? 'something_went_wrong'.tr;
    }
  }

  Future<void> firebaseVerifyPhoneNumber(
    String phoneNumber,
    String? token,
    String loginType, {
    bool fromSignUp = true,
    bool canRoute = true,
    UpdateUserModel? updateUserModel,
  }) async {
    // Prevent rapid-fire OTP requests
    if (_isRateLimited()) return;

    _isLoading = true;
    update();

    developer.log(
      'Firebase Phone Auth: requesting OTP for $phoneNumber '
      '(resendToken: $_forceResendingToken)',
      name: 'AuthController',
    );

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _forceResendingToken,

        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification (e.g. on Android with SMS Retriever).
          // We intentionally leave this empty because the backend
          // handles verification via the session id + OTP code.
          developer.log(
            'Firebase Phone Auth: auto-verification completed',
            name: 'AuthController',
          );
        },

        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          update();

          developer.log(
            'Firebase Phone Auth FAILED: code=${e.code}, message=${e.message}',
            name: 'AuthController',
            error: e,
          );

          showCustomSnackBar(_friendlyFirebaseError(e));
        },

        codeSent: (String vId, int? resendToken) {
          _isLoading = false;
          _forceResendingToken = resendToken;
          _lastOtpRequestTime = DateTime.now();
          update();

          developer.log(
            'Firebase Phone Auth: code sent, vId=$vId, resendToken=$resendToken',
            name: 'AuthController',
          );

          if (updateUserModel != null) {
            updateUserModel.sessionInfo = vId;
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
                firebaseSession: vId,
                userModel: updateUserModel,
              ));
            } else {
              Get.toNamed(RouteHelper.getVerificationRoute(
                phoneNumber, '', token,
                fromSignUp ? RouteHelper.signUp : RouteHelper.forgotPassword,
                '', loginType,
                session: vId,
                updateUserModel: updateUserModel,
              ));
            }
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          developer.log(
            'Firebase Phone Auth: auto-retrieval timeout for $verificationId',
            name: 'AuthController',
          );
        },
      );
    } catch (e) {
      _isLoading = false;
      update();
      developer.log(
        'Firebase Phone Auth: unexpected error: $e',
        name: 'AuthController',
        error: e,
      );
      showCustomSnackBar('something_went_wrong'.tr);
    }
  }

  /// Resets the resend token (e.g. when navigating away from verification).
  void resetFirebaseResendToken() {
    _forceResendingToken = null;
    _lastOtpRequestTime = null;
  }

}