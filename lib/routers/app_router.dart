import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_classification_app/features/auth/presentation/bloc/auth_bloc.dart';

import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/main/screen/main_screen.dart';
import '../features/splash/splash_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final auth = authBloc.state;
        final isSplash = state.matchedLocation == '/splash';
        final authRoute =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/forgot_password';

        if (auth is AuthInitial) {
          return isSplash ? null : '/splash';
        }

        if (auth is AuthUnauthenticated) {
          return authRoute ? null : '/login';
        }

        if (auth is AuthAuthenticated) {
          if (authRoute || isSplash) return '/main';
        }
        return null;
      },
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
          path: '/forgot_password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(path: '/main', builder: (context, state) => MainScreen()),
      ],
    );
  }
}
