import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../domain/usecases/get_profile_stream_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileStreamUseCase getProfileStreamUseCase;
  final UpdateUserProfileUsecase updateUserProfileUseCase;
  StreamSubscription? _profileSubscription;

  ProfileCubit({
    required this.getProfileStreamUseCase,
    required this.updateUserProfileUseCase,
  }) : super(ProfileInitial());

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

  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? email,
    File? newAvatarFile,
  }) async {
    emit(ProfileUpdating());
    try {
      String? uploadedAvatarUrl;
      if (newAvatarFile != null) {
        uploadedAvatarUrl = await CloudinaryService.uploadImage(newAvatarFile);
      }

      await updateUserProfileUseCase(
        userId: userId,
        fullName: fullName,
        email: email,
        avatarUrl: uploadedAvatarUrl,
      );

      emit(const ProfileUpdateSuccess('Cập nhật hồ sơ thành công!'));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
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
