import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lunchguard/core/constants/app_constants.dart';
import 'package:lunchguard/data/repositories/auth_repository.dart';
import 'package:lunchguard/features/auth/presentation/screens/login_screen.dart';
import 'package:lunchguard/features/auth/presentation/screens/register_screen.dart';
import 'package:lunchguard/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:lunchguard/features/catering/presentation/dashboard_screen.dart'
    as catering;
import 'package:lunchguard/features/school/presentation/dashboard_screen.dart'
    as school;
import 'package:lunchguard/features/splash/presentation/splash_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // [FIX] Membuat instance AuthRepository di sini untuk digunakan di redirect dan refresh
  static final AuthRepository _authRepository = AuthRepository();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/role_selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/school_dashboard',
        builder: (context, state) => const school.DashboardScreen(),
      ),
      GoRoute(
        path: '/catering_dashboard',
        builder: (context, state) => const catering.DashboardScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final user = _authRepository.currentUser;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/role_selection';

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      final userDetails = await _authRepository.getUserDetails(user.uid);

      if (userDetails != null && userDetails.role == null) {
        return state.matchedLocation == '/role_selection'
            ? null
            : '/role_selection';
      }

      if (loggingIn && userDetails != null) {
        if (userDetails.role == AppConstants.schoolRole) {
          return '/school_dashboard';
        } else if (userDetails.role == AppConstants.cateringRole) {
          return '/catering_dashboard';
        }
      }

      return null;
    },
    // [FIX] Menggunakan instance _authRepository yang sudah dibuat
    refreshListenable: GoRouterRefreshStream(_authRepository.authStateChanges),
  );
}

// Helper class untuk membuat GoRouter mendengarkan perubahan state auth
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
