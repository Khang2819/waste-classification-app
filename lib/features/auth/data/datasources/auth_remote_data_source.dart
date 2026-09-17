import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<UserModel> loginWithGoogle();
  Future<void> logout();

  Stream<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout:
                () =>
                    throw Exception(
                      'Kết nối quá thời gian. Vui lòng kiểm tra lại kết nối mạng hoặc cấu hình Firebase.',
                    ),
          );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Không tìm thấy thông tin người dùng.');
      }
      try {
        final userDoc = await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get()
            .timeout(const Duration(seconds: 4));

        if (userDoc.exists && userDoc.data() != null) {
          return UserModel.fromJson(userDoc.data()!);
        }
      } catch (_) {
        print('Firestore error: e');
      }

      return UserModel.fromFirebase(firebaseUser);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getVietnameseErrorMessage(e.code, e.message));
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Không thể đăng nhập bằng Google.');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        throw Exception('Không thể xác thực Google.');
      }
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Không thể xác thực người dùng Google.');
      }

      final doc =
          await firestore.collection('users').doc(firebaseUser.uid).get();
      if (!doc.exists) {
        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: firebaseUser.displayName ?? '',
          avatar: firebaseUser.photoURL,
          greenPoints: 0,
          totalXP: 0,
          totalScanned: 0,
          dailyScanCount: 0,
          lastScanDate: '',
          createdAt: DateTime.now(),
        );

        await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toJson());

        return newUser;
      }

      if (doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }

      return UserModel.fromFirebase(firebaseUser);
    } catch (e) {
      throw Exception('Không thể đăng nhập bằng Google: $e');
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout:
                () =>
                    throw Exception(
                      'Kết nối quá thời gian. Vui lòng kiểm tra lại kết nối mạng hoặc cấu hình Firebase.',
                    ),
          );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Không thể tạo tài khoản người dùng.');
      }

      try {
        await firebaseUser.updateDisplayName(fullName);
      } catch (_) {}

      final userModel = UserModel(
        id: firebaseUser.uid,
        fullName: fullName,
        email: email,
        avatar: firebaseUser.photoURL,
        greenPoints: 0,
        totalXP: 0,
        totalScanned: 0,
        dailyScanCount: 0,
        lastScanDate: '',
        createdAt: DateTime.now(),
      );
      try {
        await firestore
            .collection('users')
            .doc(userModel.id)
            .set(userModel.toJson())
            .timeout(const Duration(seconds: 4));
      } catch (_) {}

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getVietnameseErrorMessage(e.code, e.message));
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Không thể đăng xuất: $e');
    }
  }

  @override
  Stream<UserModel?> getCurrentUser() {
    return firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) {
        return null;
      }
      return UserModel.fromFirebase(firebaseUser);
    });
  }

  String _getVietnameseErrorMessage(String code, String? defaultMessage) {
    switch (code) {
      case 'user-not-found':
        return 'Tài khoản không tồn tại.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác.';
      case 'invalid-credential':
      case 'invalid-email':
        return 'Email hoặc mật khẩu không đúng định dạng / không chính xác.';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký cho tài khoản khác.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra lại kết nối internet.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập bằng Email/Mật khẩu chưa được bật trên Firebase Console.';
      case 'too-many-requests':
        return 'Đã thử quá nhiều lần. Vui lòng thử lại sau ít phút.';
      default:
        return defaultMessage ?? 'Đã xảy ra lỗi authentication.';
    }
  }
}
