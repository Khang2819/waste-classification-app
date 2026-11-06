import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:waste_classification_app/core/services/cloudinary_service.dart';
import 'package:waste_classification_app/features/history/data/models/history_models.dart';

abstract class HistoryRemoteDataSources {
  Stream<List<HistoryModels>> getAllHistory(String userId);
  Future<void> deleteHistory(String userId, String historyId);
  Future<void> saveHistory(String userId, HistoryModels history);
}

class HistoryRemoteDataSourcesImpl implements HistoryRemoteDataSources {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<HistoryModels>> getAllHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_histories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HistoryModels.fromToFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> deleteHistory(String userId, String historyId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_histories')
        .doc(historyId)
        .delete();
  }

  @override
  Future<void> saveHistory(String userId, HistoryModels history) async {
    String finalImagePath = history.imagePath;

    // Tự động tải ảnh lên Cloudinary nếu là đường dẫn file cục bộ
    if (finalImagePath.isNotEmpty && !finalImagePath.startsWith('http')) {
      try {
        final cleanPath = finalImagePath.replaceFirst('file://', '');
        final file = File(cleanPath);
        if (await file.exists()) {
          final uploadedUrl = await CloudinaryService.uploadImage(file);
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            finalImagePath = uploadedUrl;
          }
        }
      } catch (e) {
        debugPrint('Tải ảnh phân loại lên Cloudinary không thành công: $e');
      }
    }

    final now = DateTime.now();
    // Tạo chuỗi ngày hôm nay dạng: 2026-10-20
    final todayStr =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final userDocRef = _firestore.collection('users').doc(userId);
    final historyDocRef = userDocRef.collection('scan_histories').doc();

    await _firestore.runTransaction((transaction) async {
      final userSnap = await transaction.get(userDocRef);
      final userData = userSnap.data() ?? {};

      final lastScanDate = userData['lastScanDate'] as String? ?? '';
      final currentDailyCount =
          (userData['dailyScanCount'] as num?)?.toInt() ?? 0;

      int newDailyCount = 1;
      int pointsToAdd = 10;

      if (lastScanDate == todayStr) {
        if (currentDailyCount >= 20) {
          pointsToAdd = 0;
          newDailyCount = currentDailyCount + 1;
        } else {
          newDailyCount = currentDailyCount + 1;
        }
      } else {
        newDailyCount = 1;
      }
      final historyToSave = HistoryModels(
        id: historyDocRef.id,
        userId: userId,
        label: history.label,
        category: history.category,
        confidence: history.confidence,
        instruction: history.instruction,
        imagePath: finalImagePath,
        pointsEarned: pointsToAdd,
        createdAt: now,
      );
      transaction.set(historyDocRef, historyToSave.toFirestore());
      final Map<String, dynamic> userUpdates = {
        'totalScanned': FieldValue.increment(1),
        'lastScanDate': todayStr,
        'dailyScanCount': newDailyCount,
        'lastActiveAt': FieldValue.serverTimestamp(),
      };

      if (pointsToAdd > 0) {
        userUpdates['totalXP'] = FieldValue.increment(pointsToAdd);
        userUpdates['greenPoints'] = FieldValue.increment(pointsToAdd);
      }

      transaction.set(userDocRef, userUpdates, SetOptions(merge: true));
    });
  }
}
