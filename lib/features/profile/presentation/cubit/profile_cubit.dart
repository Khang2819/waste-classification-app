import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_profile_stream_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileStreamUseCase getProfileStreamUseCase;
  StreamSubscription? _profileSubscription;

  ProfileCubit({required this.getProfileStreamUseCase})
    : super(ProfileInitial());

  void watchProfile(String userId) {
    if (userId.isEmpty) return;
    emit(ProfileLoading());
    _profileSubscription?.cancel();
    _profileSubscription = getProfileStreamUseCase(userId).listen(
      (user) {
        emit(ProfileLoaded(user));
      },
      onError: (e) {
        emit(ProfileError(e.toString()));
      },
    );
  }

  void clear() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    emit(ProfileInitial());
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
