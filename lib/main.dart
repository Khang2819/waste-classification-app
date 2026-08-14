import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waste_classification_app/core/di/injection.dart';
import 'package:waste_classification_app/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:waste_classification_app/firebase_options.dart';
import 'package:waste_classification_app/routers/app_router.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/cubit/register/register_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(AppStarted()),
        ),
        BlocProvider(create: (_) => getIt<LoginCubit>()),
        BlocProvider(create: (_) => getIt<RegisterCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
    );
  }
}
