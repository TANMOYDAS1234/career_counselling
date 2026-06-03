import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/landing_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/signup_page.dart';
import '../../features/career_report/career_report_page.dart';
import '../../features/common/not_found_page.dart';
import '../../features/job_detail/job_detail_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/payment/payment_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/recommendations/recommendations_page.dart';
import '../../features/settings/settings_page.dart';

/// App route names/paths, mirroring the web router.
abstract class Routes {
  static const landing = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const onboarding = '/onboarding';
  static const recommendations = '/recommendations';
  static const role = '/role'; // /role/:roleId
  static const careerReport = '/career-report';
  static const profile = '/profile';
  static const payment = '/payment';
  static const settings = '/settings';
}

/// Routes that require an authenticated user.
const _protectedPrefixes = [
  Routes.onboarding,
  Routes.recommendations,
  Routes.role,
  Routes.careerReport,
  Routes.profile,
  Routes.payment,
  Routes.settings,
];

final goRouterProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod auth changes to go_router so redirects re-run on login/logout.
  final refresh = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.landing,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    errorBuilder: (_, _) => const NotFoundPage(),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      if (!auth.bootstrapped) return null;
      final loggedIn = auth.isAuthenticated;
      final loc = state.matchedLocation;
      final isProtected = _protectedPrefixes.any((p) => loc == p || loc.startsWith('$p/'));
      if (!loggedIn && isProtected) return Routes.login;
      return null;
    },
    routes: [
      GoRoute(path: Routes.landing, builder: (_, _) => const LandingPage()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
      GoRoute(path: Routes.signup, builder: (_, _) => const SignupPage()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: Routes.recommendations,
        builder: (_, _) => const RecommendationsPage(),
      ),
      GoRoute(
        path: Routes.payment,
        builder: (_, state) =>
            PaymentPage(jobIndex: state.uri.queryParameters['job'] ?? '0'),
      ),
      GoRoute(
        path: '${Routes.role}/:roleId',
        builder: (_, state) => JobDetailPage(roleId: state.pathParameters['roleId'] ?? ''),
      ),
      GoRoute(
        path: Routes.careerReport,
        builder: (_, _) => const CareerReportPage(),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (_, _) => const ProfilePage(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => const SettingsPage(),
      ),
    ],
  );
});
