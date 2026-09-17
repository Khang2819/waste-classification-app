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

import '../../features/scan/data/datasources/scan_remote_data_sources.dart';
import '../../features/scan/data/repositories/scan_repository_impl.dart';
import '../../features/scan/domain/repositories/scan_repository.dart';
import '../../features/scan/domain/usecases/scan_waste.dart';
import '../../features/scan/presentation/cubit/scan_cubit.dart';

import 'package:waste_classification_app/features/history/data/datasources/history_remote_data_sources.dart';
import 'package:waste_classification_app/features/history/data/repositories/history_repository_impl.dart';
import 'package:waste_classification_app/features/history/domain/repositories/history_repository.dart';
import 'package:waste_classification_app/features/history/domain/usecases/history_usecases.dart';
import 'package:waste_classification_app/features/history/presentation/cubit/history_cubit.dart';

import 'package:waste_classification_app/features/reward/data/datasources/reward_remote_data_sources.dart';
import 'package:waste_classification_app/features/reward/data/repositories/reward_repository_impl.dart';
import 'package:waste_classification_app/features/reward/domain/repositories/reward_repository.dart';
import 'package:waste_classification_app/features/reward/domain/usecases/reward.dart';
import 'package:waste_classification_app/features/reward/presentation/cubit/reward_cubit.dart';

import 'package:waste_classification_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:waste_classification_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:waste_classification_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:waste_classification_app/features/profile/domain/usecases/get_profile_stream_usecase.dart';
import 'package:waste_classification_app/features/profile/presentation/cubit/profile_cubit.dart';

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
  getIt.registerFactory(() => ScanCubit(scanWasteUseCase: getIt()));
  getIt.registerFactory(
    () => HistoryCubit(
      deleteHistoryUsecases: getIt(),
      getScanHistoriesUseCase: getIt(),
      saveHistoryUsecases: getIt(),
    ),
  );
  getIt.registerFactory(() => RewardCubit(rewardUsecase: getIt()));
  getIt.registerFactory(
    () => ProfileCubit(getProfileStreamUseCase: getIt()),
  );

  getIt.registerFactory(() => GetCurrentUserUseCase(getIt()));
  getIt.registerFactory(() => LogoutUseCase(getIt()));
  //case

  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => GoogleUsecase(getIt()));
  getIt.registerLazySingleton(() => ScanWaste(getIt()));

  getIt.registerLazySingleton(() => GetScanHistoriesUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteHistoryUsecases(getIt()));
  getIt.registerLazySingleton(() => SaveHistoryUsecases(getIt()));
  getIt.registerLazySingleton(() => Reward(getIt()));
  getIt.registerLazySingleton(() => GetProfileStreamUseCase(getIt()));

  //Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<ScanRepository>(
    () => ScanRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(remoteDataSources: getIt()),
  );
  getIt.registerLazySingleton<RewardRepository>(
    () => RewardRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: getIt()),
  );

  // data
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<ScanRemoteDataSource>(
    () => ScanRemoteDataSourceImpl(),
  );
  getIt.registerLazySingleton<HistoryRemoteDataSources>(
    () => HistoryRemoteDataSourcesImpl(),
  );
  getIt.registerLazySingleton<RewardRemoteDataSources>(
    () => RewardRemoteDataSourcesImpl(),
  );
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );
}
