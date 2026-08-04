import 'package:go_router/go_router.dart';
import 'package:waste_classification_app/screens/login_screen.dart';
import 'package:waste_classification_app/screens/splash_screen.dart';

import '../screens/home_screen.dart';
import '../screens/register_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/register',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
    ],
  );
}
