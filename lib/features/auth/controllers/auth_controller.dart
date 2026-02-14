import 'package:flutter/foundation.dart';
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
import 'package:stackfood_multivendor/features/verification/controllers/verification_controller.dart';
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

  bool _isNumberLogin = true;
  bool get isNumberLogin => _isNumberLogin;

  var countryDialCode = "+880";

  bool _isOtpViewEnable = true;
  bool get isOtpViewEnable => _isOtpViewEnable;

  // OTP View Management
  bool _isOtpViewActive = false;
  bool get isOtpViewActive => _isOtpViewActive;

  // Phone number for OTP flow
  String _otpPhoneNumber = '';
  String get otpPhoneNumber => _otpPhoneNumber;

  // Session ID for Firebase verification
  String? _firebaseSessionId;
  String? get firebaseSessionId => _firebaseSessionId;

  // User model for sign up flow
  UpdateUserModel? _userModelForSignUp;
  UpdateUserModel? get userModelForSignUp => _userModelForSignUp;

  // Login type
  String _loginType = 'manual';
  String get loginType => _loginType;

  // ==================== Authentication Methods ====================

  Future<ResponseModel> login({
    required String emailOrPhone,
    required String password,
    required String loginType,
    required String fieldType,
    bool alreadyInApp = false,
  }) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.login(
      emailOrPhone: emailOrPhone,
      password: password,
      loginType: loginType,
      fieldType: fieldType,
      alreadyInApp: alreadyInApp,
    );
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> otpLogin({
    required String phone,
    required String loginType,
    required String otp,
    required String verified,
    bool alreadyInApp = false,
  }) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.otpLogin(
      phone: phone,
      otp: otp,
      loginType: loginType,
      verified: verified,
      alreadyInApp: alreadyInApp,
    );
    _getUserAndCartData(responseModel);
    _isLoading = false;
    update();
    return responseModel;
  }

  // ==================== OTP Methods ====================

  /// Send OTP to phone number using Firebase Auth
  Future<ResponseModel> sendOTP({
    required String phoneNumber,
    String? token,
    String loginType = 'manual',
  }) async {
    try {
      _isLoading = true;
      update();

      // Use Firebase phone verification to send OTP
      await firebaseVerifyPhoneNumber(
        phoneNumber,
        token,
        loginType,
        fromSignUp: false,
        canRoute: false,
      );

      _isLoading = false;
      update();
      return ResponseModel(true, 'otp_sent_successfully'.tr);
    } catch (e) {
      _isLoading = false;
      update();
      showCustomSnackBar('failed_to_send_otp'.tr);
      return ResponseModel(false, 'failed_to_send_otp'.tr);
    }
  }

  /// Verify OTP and complete authentication
  Future<ResponseModel> verifyOTP({
    required String phoneNumber,
    required String otp,
    String? session,
    String? token,
    bool isSignUp = false,
    String loginType = 'manual',
  }) async {
    try {
      _isLoading = true;
      update();

      // Call backend API to verify OTP and complete authentication
      ResponseModel responseModel = await authServiceInterface.otpLogin(
        phone: phoneNumber,
        otp: otp,
        loginType: loginType,
        verified: '1',
        alreadyInApp: false,
      );

      _isLoading = false;
      update();

      if (responseModel.isSuccess) {
        // Update user info and cart data
        _getUserAndCartData(responseModel);
      }

      return responseModel;
    } catch (e) {
      _isLoading = false;
      update();
      showCustomSnackBar('otp_verification_failed'.tr);
      return ResponseModel(false, 'otp_verification_failed'.tr);
    }
  }

  /// Verify OTP using Firebase (alternative method)
  Future<ResponseModel> verifyFirebaseOtp({
    required String phoneNumber,
    required String otp,
    required String session,
    String? token,
    bool isSignUp = false,
    String loginType = 'manual',
  }) async {
    try {
      _isLoading = true;
      update();

      // Call backend API to verify OTP and complete authentication with Firebase session
      ResponseModel responseModel = await authServiceInterface.otpLogin(
        phone: phoneNumber,
        otp: otp,
        loginType: loginType,
        verified: '1',
        alreadyInApp: false,
      );

      _isLoading = false;
      update();

      if (responseModel.isSuccess) {
        // Update user info and cart data
        _getUserAndCartData(responseModel);
      }

      return responseModel;
    } catch (e) {
      _isLoading = false;
      update();
      showCustomSnackBar('otp_verification_failed'.tr);
      return ResponseModel(false, 'otp_verification_failed'.tr);
    }
  }

  /// Firebase phone verification with enhanced error handling
  Future<void> firebaseVerifyPhoneNumber(
    String phoneNumber,
    String? token,
    String loginType, {
    bool fromSignUp = true,
    bool canRoute = true,
    UpdateUserModel? updateUserModel,
    Function(String vId)? onCodeSent,
  }) async {
    _isLoading = true;
    update();

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval completed
          _isLoading = false;
          update();
          
          // Sign in with credential
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            
            if (canRoute) {
              _handleVerificationSuccess(
                phoneNumber: phoneNumber,
                fromSignUp: fromSignUp,
                loginType: loginType,
                token: token,
                updateUserModel: updateUserModel,
              );
            }
          } catch (e) {
            showCustomSnackBar('failed_to_sign_in'.tr);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _isLoading = false;
          update();

          if (e.code == 'invalid-phone-number') {
            showCustomSnackBar('please_submit_a_valid_phone_number'.tr);
          } else if (e.code == 'quota-exceeded') {
            showCustomSnackBar('sms_quota_exceeded'.tr);
          } else if (e.code == 'invalid-verification-code') {
            showCustomSnackBar('invalid_verification_code'.tr);
          } else {
            showCustomSnackBar(e.message?.replaceAll('_', ' ') ?? 'verification_failed'.tr);
          }
        },
        codeSent: (String vId, int? resendToken) async {
          _isLoading = false;
          update();

          // Store session ID
          _firebaseSessionId = vId;
          
          if (updateUserModel != null) {
            updateUserModel.sessionInfo = vId;
          }

          if (onCodeSent != null) {
            onCodeSent(vId);
          }

          if (canRoute) {
            _handleVerificationSuccess(
              phoneNumber: phoneNumber,
              fromSignUp: fromSignUp,
              loginType: loginType,
              token: token,
              updateUserModel: updateUserModel,
              sessionId: vId,
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _firebaseSessionId = verificationId;
          update();
        },
      );
    } catch (e) {
      _isLoading = false;
      update();
      showCustomSnackBar('verification_failed'.tr);
    }
  }

  /// Handle verification success and route to OTP screen
  void _handleVerificationSuccess({
    required String phoneNumber,
    required bool fromSignUp,
    required String loginType,
    String? token,
    UpdateUserModel? updateUserModel,
    String? sessionId,
  }) {
    _otpPhoneNumber = phoneNumber;
    _loginType = loginType;
    _userModelForSignUp = updateUserModel;
    _isOtpViewActive = true;
    update();

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
        firebaseSession: sessionId,
        userModel: updateUserModel,
      ));
    } else {
      Get.toNamed(RouteHelper.getVerificationRoute(
        phoneNumber,
        '',
        token,
        fromSignUp ? RouteHelper.signUp : RouteHelper.forgotPassword,
        '',
        loginType,
        session: sessionId,
        updateUserModel: updateUserModel,
      ));
    }
  }

  // ==================== User Management ====================

  Future<void> _getUserAndCartData(ResponseModel responseModel) async {
    if (responseModel.authResponseModel != null) {
      await Get.find<ProfileController>().getUserInfo();
      await Get.find<CartController>().getCartDataOnline();
    }
  }

  // ==================== Remember Me ====================

  void toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    update();
  }

  void toggleRememberMeForOtp() {
    _isActiveRememberMeForOtp = !_isActiveRememberMeForOtp;
    update();
  }

  void toggleIsNumberLogin({bool value = true}) {
    _isNumberLogin = value;
    update();
  }

  void resetOtpView({bool isUpdate = true}) {
    _isOtpViewActive = false;
    _otpPhoneNumber = '';
    _firebaseSessionId = null;
    _userModelForSignUp = null;
    if (isUpdate) {
      update();
    }
  }

  void initCountryCode({String? countryCode}) {
    if (countryCode != null && countryCode.isNotEmpty) {
      countryDialCode = countryCode;
      update();
    }
  }

  // ==================== Session Management ====================

  bool isLoggedIn() {
    return authServiceInterface.isLoggedIn();
  }

  String getUserToken() {
    return authServiceInterface.getUserToken();
  }

  Future<bool> clearSharedData({bool removeToken = true}) async {
    // Clear auth data
    return await authServiceInterface.clearSharedData(removeToken: removeToken);
  }

  Future<void> socialLogout() async {
    await authServiceInterface.socialLogout();
    resetOtpView();
  }

  // ==================== User Data Management ====================

  void saveUserNumberAndPassword({
    required String number,
    required String password,
    required String countryCode,
    required String otpPoneNumber,
  }) {
    authServiceInterface.saveUserNumberAndPassword(
      number: number,
      password: password,
      countryCode: countryCode,
      otpPoneNumber: otpPoneNumber,
    );
  }

  Future<bool> clearUserNumberAndPassword() async {
    return await authServiceInterface.clearUserNumberAndPassword();
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

  // ==================== Notification Settings ====================

  Future<bool> setNotificationActive(bool isActive) async {
    await authServiceInterface.setNotificationActive(isActive);
    _notification = isActive;
    update();
    return isActive;
  }

  bool isNotificationActive() {
    return authServiceInterface.isNotificationActive();
  }

  // ==================== Guest Login ====================

  Future<ResponseModel> guestLogin() async {
    _guestLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.guestLogin();
    _guestLoading = false;
    update();
    return responseModel;
  }

  // ==================== Update Personal Info ====================

  Future<ResponseModel> updatePersonalInfo({
    required String name,
    required String? phone,
    required String loginType,
    required String? email,
    required String? referCode,
    bool alreadyInApp = false,
  }) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.updatePersonalInfo(
      name: name,
      phone: phone,
      loginType: loginType,
      email: email,
      referCode: referCode,
      alreadyInApp: alreadyInApp,
    );
    _isLoading = false;
    update();
    return responseModel;
  }

  // ==================== Phone Number Validation ====================

  Future<bool> validatePhoneNumber(String phoneNumber) async {
    // Basic phone number validation
    if (phoneNumber.isEmpty) {
      return false;
    }
    
    // Remove any non-digit characters except leading +
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check if it starts with +
    if (!cleaned.startsWith('+')) {
      return false;
    }
    
    // Check length (10-15 digits after +)
    final digitsOnly = cleaned.replaceAll('+', '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return false;
    }
    
    return true;
  }

  // ==================== Cleanup ====================

  @override
  void onClose() {
    super.onClose();
    // Cleanup resources if needed
  }

  // ==================== Additional Methods ====================

  /// Toggle terms and conditions acceptance
  void toggleTerms() {
    _acceptTerms = !_acceptTerms;
    update();
  }

  /// Enable or disable OTP view
  void enableOtpView({required bool enable}) {
    _isOtpViewActive = enable;
    update();
  }

  /// Login with social media
  Future<ResponseModel> loginWithSocialMedia(
    SocialLogInBodyModel socialLogInModel, {
    bool isCustomerVerificationOn = false,
  }) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.loginWithSocialMedia(
      socialLogInModel,
      isCustomerVerificationOn: isCustomerVerificationOn,
    );
    _isLoading = false;
    update();
    return responseModel;
  }

  /// Get guest ID
  String getGuestId() {
    return authServiceInterface.getGuestId();
  }

  /// Check if guest is logged in
  bool isGuestLoggedIn() {
    return authServiceInterface.isGuestLoggedIn();
  }

  /// Save guest number
  Future<void> saveGuestNumber(String number) async {
    await authServiceInterface.saveGuestNumber(number);
  }

  /// Get guest number
  String getGuestNumber() {
    return authServiceInterface.getGuestNumber();
  }

  /// Update token
  Future<void> updateToken() async {
    await authServiceInterface.updateToken();
  }

  /// Registration with sign up model
  Future<ResponseModel> registration(SignUpBodyModel signUpModel) async {
    _isLoading = true;
    update();
    ResponseModel responseModel = await authServiceInterface.registration(signUpModel);
    _isLoading = false;
    update();
    return responseModel;
  }
}
