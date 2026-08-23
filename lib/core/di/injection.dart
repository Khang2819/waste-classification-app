import 'package:get_it/get_it.dart';
import 'package:waste_classification_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:waste_classification_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:waste_classification_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:waste_classification_app/features/auth/presentation/cubit/login/login_cubit.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/google_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/register/register_cubit.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Cubit and bloc

  getIt.registerFactory(
    () => AuthBloc(getCurrentUserUseCase: getIt(), logoutUseCase: getIt()),
  );

  getIt.registerFactory(
    () => LoginCubit(loginUseCase: getIt(), googleUsecase: getIt()),
  );
  getIt.registerFactory(() => RegisterCubit(registerUseCase: getIt()));

  getIt.registerFactory(() => GetCurrentUserUseCase(getIt()));
  getIt.registerFactory(() => LogoutUseCase(getIt()));
  //case

  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => GoogleUsecase(getIt()));

  //Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt()),
  );
  // data
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
}
