import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Stream<UserModel> getUserProfile(String userId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

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
}
