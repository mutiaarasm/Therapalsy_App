import 'package:bellspalsy_app/app/modules/auth/otp/controllers/otp_controller.dart';
import 'package:get/get.dart';

import '../modules/GreatJob/bindings/great_job_binding.dart';
import '../modules/GreatJob/views/great_job_view.dart';
import '../modules/PrivacyPolice/bindings/privacy_police_binding.dart';
import '../modules/PrivacyPolice/views/privacy_police_view.dart';
import '../modules/SelfReport/bindings/self_report_binding.dart';
import '../modules/SelfReport/views/self_report_view.dart';
import '../modules/article/bindings/article_binding.dart';
import '../modules/article/views/article_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/forgot_pass/bindings/forgot_pass_binding.dart';
import '../modules/auth/forgot_pass/views/forgot_pass_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/otp/views/otp_view.dart';
import '../modules/auth/register/bindings/register_binding.dart';
import '../modules/auth/register/views/register_view.dart';
import '../modules/auth/reset_password/bindings/auth_reset_password_binding.dart';
import '../modules/auth/reset_password/views/auth_reset_password_view.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/auth/views/welcome_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/detection/bindings/detection_binding.dart';
import '../modules/detection/views/detection_view.dart';
import '../modules/faq/bindings/faq_binding.dart';
import '../modules/faq/views/faq_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/signInHistory_view.dart';
import '../modules/progress/bindings/progress_binding.dart';
import '../modules/progress/views/progress_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/therapy/bindings/therapy_binding.dart';
import '../modules/therapy/views/therapy_view.dart';
import '../modules/profile/bindings/profile_binding.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
      children: [
        GetPage(
          name: _Paths.WELCOME,
          page: () => const WelcomeView(),
        ),
        GetPage(
          name: _Paths.LOGIN,
          page: () => const LoginView(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: _Paths.REGISTER,
          page: () => const RegisterView(),
          binding: RegisterBinding(),
        ),
        GetPage(
          name: _Paths.FORGOT_PASS,
          page: () => const ForgotPassView(),
          binding: ForgotPassBinding(),
        ),
        GetPage(
          name: _Paths.RESET_PASSWORD,
          page: () => const ResetPasswordView(),
          binding: AuthResetPasswordBinding(),
        ),
      ],
    ),
    GetPage(
            name: Routes.OTP,
            page: () => const OtpView(),
            binding: BindingsBuilder(() {
              Get.lazyPut<OtpController>(
                () => OtpController(),
              );
            }),
          ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DETECTION,
      page: () => const DetectionView(),
      binding: DetectionBinding(),
    ),
    GetPage(
      name: _Paths.PROGRESS,
      page: () => const ProgressView(),
      binding: ProgressBinding(),
    ),
    GetPage(
      name: _Paths.THERAPY,
      page: () => const TherapyView(),
      binding: TherapyBinding(),
    ),
    GetPage(
      name: _Paths.FAQ,
      page: () => const FaqScreen(),
      binding: FaqBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICE,
      page: () => const PrivacyPoliceView(),
      binding: PrivacyPoliceBinding(),
    ),
    GetPage(
      name: _Paths.SELF_REPORT,
      page: () => const SelfReportView(),
      binding: SelfReportBinding(),
    ),
    GetPage(
      name: _Paths.GREAT_JOB,
      page: () => const GreatJobView(),
      binding: GreatJobBinding(),
    ),
    GetPage(
      name: Routes.SIGN_IN_HISTORY,
      page: () => const SignInHistoryView(),
    ),
    GetPage(
      name: _Paths.ARTICLE,
      page: () => const ArticleView(),
      binding: ArticleBinding(),
    ),
  ];
}
