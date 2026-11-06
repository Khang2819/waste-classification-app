import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Stream<UserModel> getUserProfile(String userId);
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? email,
    String? avatarUrl,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<void> createPassword({
    required String newPassword,
  });
  Future<void> sendPasswordResetEmail();
  bool get isPasswordLinked;
  bool get isGoogleLinked;
  String? get currentUserEmail;
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : firestore = firestore ?? FirebaseFirestore.instance,
       firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  bool get isPasswordLinked =>
      firebaseAuth.currentUser?.providerData.any(
        (info) => info.providerId == 'password',
      ) ??
      false;

  @override
  bool get isGoogleLinked =>
      firebaseAuth.currentUser?.providerData.any(
        (info) => info.providerId == 'google.com',
      ) ??
      false;

  @override
  String? get currentUserEmail => firebaseAuth.currentUser?.email;

  @override
  Stream<UserModel> getUserProfile(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();
      if (snapshot.exists && data != null) {
        final map = Map<String, dynamic>.from(data);
        map['id'] = userId;
        return UserModel.fromJson(map);
      }
      return UserModel(id: userId, fullName: 'Người dùng', email: '');
    });
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required String fullName,
    String? email,
    String? avatarUrl,
  }) async {
    final currentUser = firebaseAuth.currentUser;
    final Map<String, dynamic> updateData = {'full_name': fullName.trim()};

    // 1. Cập nhật Auth Display Name
    if (currentUser != null && currentUser.displayName != fullName.trim()) {
      await currentUser.updateDisplayName(fullName.trim());
    }

    // 2. Cập nhật Avatar (nếu có URL mới)
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      updateData['avatar'] = avatarUrl;
      if (currentUser != null) {
        await currentUser.updatePhotoURL(avatarUrl);
      }
    }

    // 3. Cập nhật Email (Xác thực email nếu thay đổi)
    if (email != null && email.trim().isNotEmpty && currentUser != null) {
      final newEmail = email.trim();
      if (currentUser.email != newEmail) {
        await currentUser.verifyBeforeUpdateEmail(newEmail);
        updateData['email'] = newEmail;
      }
    }

    // 4. Lưu đồng bộ thông tin vào Firestore
    await firestore.collection('users').doc(userId).update(updateData);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('Người dùng chưa đăng nhập.');
    }

    final email = currentUser.email;
    if (email == null || email.isEmpty) {
      throw Exception('Tài khoản không có email để đổi mật khẩu.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Mật khẩu hiện tại không chính xác.');
        case 'weak-password':
          throw Exception('Mật khẩu mới quá yếu (tối thiểu 6 ký tự).');
        case 'requires-recent-login':
          throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        case 'network-request-failed':
          throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra lại đường truyền internet.');
        default:
          throw Exception(e.message ?? 'Đổi mật khẩu thất bại.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Không thể đổi mật khẩu: $e');
    }
  }

  @override
  Future<void> createPassword({
    required String newPassword,
  }) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      throw Exception('Người dùng chưa đăng nhập.');
    }

    final email = currentUser.email;
    if (email == null || email.isEmpty) {
      throw Exception('Tài khoản không có email để tạo mật khẩu.');
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: newPassword,
      );
      await currentUser.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw Exception('Mật khẩu quá yếu (tối thiểu 6 ký tự).');
        case 'provider-already-linked':
          await currentUser.updatePassword(newPassword);
          break;
        case 'credential-already-in-use':
          throw Exception('Email này đã được dùng cho tài khoản mật khẩu khác.');
        case 'requires-recent-login':
          throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
        case 'network-request-failed':
          throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra lại đường truyền internet.');
        default:
          throw Exception(e.message ?? 'Tạo mật khẩu thất bại.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Không thể tạo mật khẩu: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail() async {
    final email = currentUserEmail;
    if (email == null || email.isEmpty) {
      throw Exception('Không tìm thấy email của tài khoản.');
    }

    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Không thể gửi email đặt lại mật khẩu.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
}
