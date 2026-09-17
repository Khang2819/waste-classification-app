import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:waste_classification_app/core/di/injection.dart';
import 'package:waste_classification_app/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:waste_classification_app/firebase_options.dart';
import 'package:waste_classification_app/routers/app_router.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/cubit/register/register_cubit.dart';
import 'features/history/presentation/cubit/history_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/reward/presentation/cubit/reward_cubit.dart';
import 'features/scan/presentation/cubit/scan_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<ProfileCubit>().watchProfile(state.user.id);
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
        routerConfig: AppRouter.createRouter(context.read<AuthBloc>()),
      ),
    );
  }
}
