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
}
