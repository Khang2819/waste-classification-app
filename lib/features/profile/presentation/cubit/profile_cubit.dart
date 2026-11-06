import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../domain/usecases/get_profile_stream_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileStreamUseCase getProfileStreamUseCase;
  final UpdateUserProfileUsecase updateUserProfileUseCase;
  StreamSubscription? _profileSubscription;
  String? _watchedUserId;
  User? _currentUser;

  ProfileCubit({
    required this.getProfileStreamUseCase,
    required this.updateUserProfileUseCase,
  }) : super(const ProfileInitial());

  User? get currentUser => _currentUser;

  void watchProfile(String userId) {
    if (userId.isEmpty) return;

    // Nếu đã đang lắng nghe chính userId này và đã có dữ liệu, không reset về loading
    if (_watchedUserId == userId && _profileSubscription != null) {
      if (_currentUser != null) {
        emit(ProfileLoaded(_currentUser!));
      }
      return;
    }

    _watchedUserId = userId;
    emit(ProfileLoading(user: _currentUser));
    _profileSubscription?.cancel();
    _profileSubscription = getProfileStreamUseCase(userId).listen(
      (user) {
        _currentUser = user;
        emit(ProfileLoaded(user));
      },
      onError: (e) {
        emit(ProfileError(e.toString(), user: _currentUser));
      },
    );
  }

  Future<void> updateProfile({
    required String userId,
    required String fullName,
    String? email,
    File? newAvatarFile,
  }) async {
    emit(ProfileUpdating(user: _currentUser));
    try {
      String? uploadedAvatarUrl;
      if (newAvatarFile != null) {
        uploadedAvatarUrl = await CloudinaryService.uploadImage(newAvatarFile);
        if (uploadedAvatarUrl == null || uploadedAvatarUrl.isEmpty) {
          throw Exception('Không thể tải ảnh đại diện lên máy chủ. Vui lòng thử lại!');
        }
      }

      await updateUserProfileUseCase(
        userId: userId,
        fullName: fullName,
        email: email,
        avatarUrl: uploadedAvatarUrl,
      );

      // Cập nhật ngay bộ nhớ tạm để UI lập tức hiển thị avatar và tên mới
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          fullName: fullName,
          email: email ?? _currentUser!.email,
          avatar: uploadedAvatarUrl ?? _currentUser!.avatar,
          greenPoints: _currentUser!.greenPoints,
          totalXP: _currentUser!.totalXP,
          totalScanned: _currentUser!.totalScanned,
          lastScanDate: _currentUser!.lastScanDate,
          dailyScanCount: _currentUser!.dailyScanCount,
          createdAt: _currentUser!.createdAt,
          role: _currentUser!.role,
        );
      }

      emit(ProfileUpdateSuccess('Cập nhật hồ sơ thành công!', user: _currentUser));
      if (_currentUser != null) {
        emit(ProfileLoaded(_currentUser!));
      }
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', ''), user: _currentUser));
    }
  }

  void clear() {
    _profileSubscription?.cancel();
    _profileSubscription = null;
    _watchedUserId = null;
    _currentUser = null;
    emit(const ProfileInitial());
  }

  @override
  Future<void> close() {
    _profileSubscription?.cancel();
    return super.close();
  }
}
