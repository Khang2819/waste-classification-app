import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:waste_classification_app/core/di/injection.dart';
import 'package:waste_classification_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:waste_classification_app/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:waste_classification_app/features/map/presentation/cubit/map_cubit.dart';
import 'package:waste_classification_app/firebase_options.dart';
import 'package:waste_classification_app/routers/app_router.dart';

import 'core/services/fcm_service.dart';
import 'features/auth/presentation/cubit/register/register_cubit.dart';
import 'features/history/presentation/cubit/history_cubit.dart';
import 'features/notifications/domain/usecases/save_fcm_token.dart';
import 'features/notifications/presentation/cubit/notification_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/reward/presentation/cubit/reward_cubit.dart';
import 'features/scan/presentation/cubit/scan_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  await init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(AppStarted()),
        ),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<LoginCubit>()),
        BlocProvider(create: (_) => getIt<RegisterCubit>()),
        BlocProvider(create: (_) => getIt<ScanCubit>()),
        BlocProvider(create: (_) => getIt<HistoryCubit>()),
        BlocProvider(create: (_) => getIt<RewardCubit>()),
        BlocProvider(create: (_) => getIt<MapCubit>()),
        BlocProvider(create: (_) => getIt<NotificationCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

// Giữ reference của router ở đây để dùng trong onTap callback
GoRouter? _appRouter;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo router 1 lần duy nhất và lưu vào _appRouter
    _appRouter ??= AppRouter.createRouter(context.read<AuthBloc>());

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final uid = state.user.id;

          // 1. Bắt đầu stream thông báo từ Firestore
          context.read<NotificationCubit>().start(uid);

          // 2. Khởi động FCM
          FcmService().init(
            onToken: (token) => getIt<SaveFcmToken>()(uid, token),
            onTap: (message) {
              _appRouter?.push('/notification');
            },
          );

          context.read<ProfileCubit>().watchProfile(uid);
        } else if (state is AuthUnauthenticated) {
          context.read<ProfileCubit>().clear();
        }
      },
      child: MaterialApp.router(
        title: 'SmartWaste',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            primary: const Color(0xFF2E7D32),
          ),
          useMaterial3: true,
        ),
        routerConfig: _appRouter!,
      ),
    );
  }
}
