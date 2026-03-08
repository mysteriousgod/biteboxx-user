import 'package:stackfood_multivendor/features/auth/domain/centralize_login_enum.dart';
import 'package:stackfood_multivendor/features/splash/domain/models/config_model.dart';

class CentralizeLoginHelper {
  /// Always returns OTP login — phone-number-only authentication.
  /// Ignores backend config flags to enforce mobile-only sign-in.
  static ({CentralizeLoginType type, double size}) getPreferredLoginMethod(CentralizeLoginSetup data, bool isOtpViewEnable, {bool calculateWidth = false}) {
    return (type: CentralizeLoginType.otp, size: 400);
  }
}